#thingsIX installer
#starts these containers:
#   - thingsix_supervisor: stops helium multiplexer (multiplexer_*) and make sure it does not restart (loop)
#   - multiplexer: receives lora packets on 1681/udp and post them to multiple clients
#     Setup into either the helium's container network (nebra) or the main network (sensecap)
#   - thingsix-forwarder: receives lora packets from the multiplexer, and forwards them to thingsIX

#create folders
depinFolder=/mnt/data/depin;
thingsIXfolder=$depinFolder/thingsix;
folder=$thingsIXfolder
if [ ! -d $folder ]; then mkdir -p $folder; fi;
folder=$thingsIXfolder/forwarder;
if [ ! -d $folder ]; then mkdir -p $folder; fi;

function createSupervisorScript() {
    installScript='
stopPartialContainer(){
    local partialContainerName=$1

    containerName=$(isPartialContainerRunning $partialContainerName)
    if [ -n "$containerName" ]; then
        echo "stopping $containerName"
        docker stop "$containerName"
    fi
}

isPartialContainerRunning(){
    local partialContainerName=$1

    containerName=$(docker ps --filter "name=^$partialContainerName" --format "{{.Names}}")

    if [ -n "$containerName" ]; then
        containerStatus=$(docker inspect -f "{{.State.Status}}" "$containerName")
        if [[ "$containerStatus" == "running" ]]; then
            echo "$containerName";
            return;
        fi
    fi
}

removeContainer(){
    local container_name=$1

    if docker container inspect "$container_name" >/dev/null 2>&1; then
        echo "Removing container $containerName";
        docker rm -f $container_name;
    fi
}

#starts the lorawan multiplexer
#forwards UDP/1681 to target clients (helium:udp/1680, thingsIX:udp/1685)
#https://docs.thingsix.com/for-gateway-owners/multiplexing-packet
#https://github.com/ThingsIXFoundation/gwmp-mux
startLorawanMultiplexer() {
    local network=$1
    local heliumMinerIP=$2

    removeContainer "multiplexer"

    echo "Starting lorawan multiplexer."
    echo "Source: multiplexer:1681/udp, Targets: $heliumMinerIP:1680/udp (helium miner), thingsix-forwarder:1685/udp (thingsix miner)"
    docker run -d --restart unless-stopped \
        --name multiplexer \
        --hostname multiplexer \
        --network $network \
        --label=com.centurylinklabs.watchtower.enable=true \
        ghcr.io/thingsixfoundation/gwmp-mux:latest \
        --host 1681 \
        --client $heliumMinerIP:1680 \
        --client thingsix-forwarder:1685
}

#starts thingix forwarder
#(the forwarder can be replaced by a chirpstack-packet-multiplexer on a VPS instead)
#https://docs.thingsix.com/for-gateway-owners/installing-forwarder
startThingsIXForwarder() {
    local network=$1

    removeContainer "thingsix-forwarder"

    #Install thingix forwader on 1685/udp using the custom config file
    echo "Starting thingsix forwarder"
    docker run -d --restart unless-stopped  \
        --name thingsix-forwarder \
        --network $network \
        --hostname thingsix-forwarder \
        -v '"$thingsIXfolder"'/forwarder:/etc/thingsix-forwarder \
        -v '"$thingsIXfolder"'/forwarder_config.yaml:/etc/thingsix-forwarder/forwarder_config.yaml \
        --label=com.centurylinklabs.watchtower.enable=true \
        ghcr.io/thingsixfoundation/packet-handling/forwarder:latest \
        --config /etc/thingsix-forwarder/forwarder_config.yaml
}

run() {
    echo "starting container check loop"

    while true; do
        sleep 10  # Wait 10s

        containerName=$(isPartialContainerRunning "multiplexer_")
        thingsIXforwarder=$(isPartialContainerRunning "thingsix-forwarder")

        if [ "$containerName" != "" ] || [ "$thingsIXforwarder" == "" ]; then

            if [ "$containerName" != "" ]; then
                echo "detected another multiplexer running. updating."
            elif [ "$thingsIXforwarder" == "" ]; then
                echo "detected that the thingsIX fowarder is not running. updating."
            fi
        
            #network in use inside existing device
            network=$(docker network ls --filter "driver=bridge" --format "{{.Name}}" | grep "_default$")

            #helium miner IP
            containerName=$(docker ps --filter "name=^helium-miner_" --format "{{.Names}}")
            heliumMinerIP=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $containerName)

            if [ "$heliumMinerIP" == "" ]; then
                echo "error: container helium-miner_* not found. Can not continue"
                return
            else
                stopPartialContainer "multiplexer_"
                startThingsIXForwarder "$network"
                sleep 5  # Wait 5s
                startLorawanMultiplexer "$network" "$heliumMinerIP"
                sleep 5  # Wait 5s
                packetForwarderContainerName=$(docker ps --filter "name=^packet-forwarder_" --format "{{.Names}}")
                docker restart "$packetForwarderContainerName"
                echo "Dual mining with thingsIX Installed on this miner"
                echo "Check forwarder logs with:"
                echo "balena logs -f multiplexer"
                echo "balena logs -f thingsix-forwarder"
            fi
        fi

        sleep 60  # Wait 60s
    done
}

run
'

    echo "$installScript" > $thingsIXfolder/thingsix_supervisor.sh


    #start thingsIX forwader
    #Make thingsIX forwarder listen to udp/1685
    #disable API on 127.0.0.1:8080
    #don't make prometheus public
    #https://github.com/ThingsIXFoundation/packet-handling/blob/main/cmd/forwarder/example-config.yaml
    echo '
forwarder:
    backend:
        semtech_udp:
            udp_bind: 0.0.0.0:1685
    gateways:
        api:
            address: 127.0.0.1:8085

metrics:
    prometheus:
        address: 127.0.0.1:8885

' > $thingsIXfolder/forwarder_config.yaml
}


function startSupervisor(){
    container_name=thingsix_supervisor
    if $hypervisor container inspect "$container_name" >/dev/null 2>&1; then $hypervisor rm -f $container_name; fi;

    $hypervisor run -d --restart unless-stopped --name $container_name \
        -v /var/run/$hypervisor.sock:/var/run/docker.sock \
        -v $thingsIXfolder/thingsix_supervisor.sh:/run.sh \
        --label=com.centurylinklabs.watchtower.enable=true \
        docker sh -c "sh /run.sh"
}

function onBoardThingsIX() {
    echo "Waiting for ThingsIX forwarder to run (>15s)"
    sleep 15
    local_id="$thingsIXfolder/forwarder/unknown_gateways.yaml"
    echo "Waiting for $local_id to appear"
    echo "It may not appear if the helium hotspot is not onboarded, or location is not asserted"
    echo "If your gateways.yaml file already exists, then your hotspot is already onboarded and"
    echo "You can stop this script with CTRL-C"
    while [ ! -f "$local_id" ]; do sleep 1; done

    echo "***********************************"
    echo "Onboarding (press enter to skip)"
    echo "***********************************"
    echo "Enter your ThingsIX Polygon Wallet ID (or nothing to skip):"
    read thingsIXWalletId
    thingsIXWalletId=$(echo "$thingsIXWalletId" | sed -e "s/^[[:space:]]*//" -e "s/[[:space:]]*$//")
    if [ -z "$thingsIXWalletId" ]; then return; fi;
    id=$(grep -m1 'local_id:' $local_id | awk '{print $3}')
    #we changed the API port to 8085 so we must use the --config flag
    $hypervisor exec thingsix-forwarder ./forwarder gateway onboard-and-push $id $thingsIXWalletId --config /etc/thingsix-forwarder/forwarder_config.yaml

    echo "Finished."
    echo "Now onboard your miner there: "
    echo "    https://app.thingsix.com/gateways/onboarding"
    echo "***********************************"
    echo "You will need some THIX, you can swap on those pools:"
    echo "   https://swap.thingsix.com/"
    echo "   https://info.uniswap.org/#/polygon/pools/0xa74d0f28fb5b4ef5fc573192d85c23ee00b52aed"
    echo ""
    echo "The THIX token contract is there (to add it to metamask): "
    echo "   https://docs.thingsix.com/developer-documentation/smart-contracts/Contracts"
    echo "***********************************"
    echo "See https://docs.thingsix.com/for-gateway-owners/connecting-wallet"
    echo "And https://docs.thingsix.com/for-gateway-owners/onboarding-gateway"
    echo "***********************************"
}

function checkBalenaDocker() {

  if command -v balena &>/dev/null; then   balena_installed=1; else   balena_installed=0; fi
  if command -v docker &>/dev/null; then   docker_installed=1; else   docker_installed=0; fi

  if [[ $docker_installed -eq 0 && $balena_installed -eq 0 ]]; then
      echo "Neither Docker nor Balena are installed. Exiting"
      exit 100;
  elif [[ $balena_installed -eq 1 ]]; then
      echo "balena"
  else
      echo "docker"
  fi
}

function displayQr() {
echo "--------------------------------------"
echo "You liked this script ?"
echo "Send me some crypto tokens :)"
echo ""
 echo "█▀▀▀▀▀█ ▀▀▀▀▄█▄▀  ▄▄▀▄▀▀█ █▀▀▀▀▀█  "
 echo "█ ███ █ ▄▄▄▀▀ ▀█▄█▀ ▀▀ █  █ ███ █  "
 echo "█ ▀▀▀ █ ███  █▄▄▀▄ ▀▄  ▀▄ █ ▀▀▀ █  "
 echo "▀▀▀▀▀▀▀ █▄▀ █ █ ▀▄▀▄█▄█▄▀ ▀▀▀▀▀▀▀  "
 echo "▀▄ ▄█▄▀▀▀█▄▀  ▀█▄█▄ ▄▀▄▄▄█▀█▀█▄▄▀  "
 echo "█ ▄ █ ▀▄ █▀▄██▀▀█ ▀  █▀██ ▄ █▀ █   "
 echo " ▄██▄█▀ █▄▀▀▀▀▄ ▀ ▄▄█▀▄▄▄▀▀▄▀ ▄▀▀  "
 echo "████▄█▀▀█▄ █▄▀██▄██ ▀█▀▀ █▀ ▄█▀█   "
 echo "▄ ▀▀  ▀▀ ▄█▄▀█▄▄▀▀▀▀▄▀▄▄▀▀▀█▀▀ ▄█  "
 echo "▀█  ▀▀▀██▄████▄▀▀█▄ ▄▄▀█    █▀ ▀▄  "
 echo "██▄▀▄▄▀▄█▄ █ ▀▄ ▄ ▀▀▀█▀▀▀▄█▀▀ ▄█▀  "
 echo "  ██▀ ▀▄▄ ▄  ▄▀ ▀▄▀ ███▀█ █ ▄  █▄  "
 echo "▀▀  ▀ ▀ ▄▄█  ▀▀█▀█▀▀▄▀▀▄█▀▀▀█▄█▀▀  "
 echo "█▀▀▀▀▀█ ▀ ▄▄█▀██▄ ▀▄██▀ █ ▀ █      "
 echo "█ ███ █ ▀████▀▀ ▀▄▄█▀▀▄ ███▀█▀▄ ▀  "
 echo "█ ▀▀▀ █  ▀   ▀ █▄█ ▄ █ ▀▄█▀▄▀▄▀    "
 echo "▀▀▀▀▀▀▀ ▀▀  ▀      ▀ ▀  ▀▀   ▀  ▀  "
echo "--------------------------------------"
}

echo "Starting ThingsIX installation on balena (for nebra, sensecap or Pisces original firmwares)"
echo "(you can run this script multiple times without any issue)"

hypervisor=$(checkBalenaDocker)

createSupervisorScript
startSupervisor
displayQr
onBoardThingsIX
echo "finished"
