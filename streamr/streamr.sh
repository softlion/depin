function installStreamr() {

  container="streamr1"
  if $runHypervisor container inspect "$container" >/dev/null 2>&1; then $runHypervisor rm -f "$container"; fi;


  startConfigWizard=true
  if [ -e "$projectFolder/config/default.json" ]; then
    result=$(prompt_with_default "Rerun the configuration wizard? (y/n)" "n")
    [ "$result" != "y" ] && startConfigWizard=false;
  fi

  if [ "$startConfigWizard" = true ]; then
    #start configuration wizard
    $runHypervisor run -it \
      --user "$(id -u):$(id -g)" \
      -v "$projectFolder":/home/streamr/.streamr \
      streamr/broker-node:latest \
      bin/config-wizard;

    #This creates the config in "$projectFolder/config/default.json"
    #Choose "Generate" for Etherum private key. Do not import an existing one !
    #Plugins to enable: press enter (do not select/enable any additional plugins).
    #Set staking key: yes (enter your eth wallet public address)
    #"Path to store the configuration": Press 'enter' (keep the default path).
  fi

  #start node
  $runHypervisor run -d --name "$container" \
    --restart unless-stopped \
    -v "$projectFolder":/home/streamr/.streamr \
    --label=com.centurylinklabs.watchtower.enable=true \
    streamr/broker-node:latest;
}


function createProjectFolder(){
    local projectRelativeFolder="$1"

    echo "Creating folders"
    depinFolder=$([ "$hypervisor" == "balena" ] && echo "/mnt/data/depin" || echo "/usr/src/depin")
    projectFolder="$depinFolder/$projectRelativeFolder";

    folder="$projectFolder"
    if [ ! -d "$folder" ]; then 
        echo "creating $folder"

        if [ "$hypervisor" = "balena" ]; then
            mkdir -p "$folder";
        else
            sudo mkdir -p "$folder";
            #sudo chown -R root "$folder"
            #sudo chmod -R u+rw "$folder"
            sudo chmod -R 777 "$folder"
        fi

        echo "done creating"
    fi;
}

function installWatchTower() {

  #install watchtower
  watchtowerContainerID=$($runHypervisor ps -aqf name="watchtower")
  if [ -z "$watchtowerContainerID" ]; then watchtowerInstalled=false; else watchtowerInstalled=true; fi

  if [[ ! $watchtowerInstalled ]]; then
    echo "Installing watchtower"

    $runHypervisor run -d \
      --name watchtower \
      --volume /var/run/$hypervisor.sock:/var/run/docker.sock \
      --label=com.centurylinklabs.watchtower.enable=true \
      containrrr/watchtower \
      --label-enable
  else
      echo "watchtower already installed. Skipping."
  fi
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

echo "Installing a container to run a mysterium node on balena or docker"
echo "(you can run this script multiple times without any issue)"

hypervisor=$(checkBalenaDocker)
runHypervisor="$([[ "$hypervisor" == "docker" ]] && echo 'sudo docker' || echo 'balena')"
echo "Using hypervisor $hypervisor and run $runHypervisor"
createProjectFolder "streamr/1"
installWatchTower
installStreamr
displayQr
echo "finished"
echo "validation: "
echo "$runHypervisor logs -f $container"
