
function createFolders(){
    echo "Creating folders"
    depinFolder=$([ "$hypervisor" == "balena" ] && echo "/mnt/data/depin" || echo "/usr/src/depin")

    folder=$depinFolder
    if [ ! -d $folder ]; then 
        echo "creating $folder"

        if [ "$hypervisor" = "balena" ]; then
            mkdir -p $folder;
        else
            sudo mkdir -p $folder;
            sudo chown -R $(whoami) $folder
            chmod -R u+rw /usr/src/depin
        fi

        echo "done creating"
    fi;

    honeygainFolder=$depinFolder/honeygain;
    folder=$honeygainFolder
    if [ ! -d $folder ]; then mkdir -p $folder; fi;
    export honeygainFolder
}


function onBoardHoneygain(){
    if [ -z "$ACCOUNT_EMAIL" ]; then
        echo "Enter your honeygain email"
        ACCOUNT_EMAIL=$(prompt_with_default "email" "")
        export ACCOUNT_EMAIL
    fi
    if [ -z "$ACCOUNT_PASSWORD" ]; then
        echo "Enter your honeygain password"
        ACCOUNT_PASSWORD=$(prompt_with_default "password" "")
        export ACCOUNT_PASSWORD
    fi
    if [ -z "$DEVICE_NAME" ]; then
        echo "Enter a name for this device"
        DEVICE_NAME=$(prompt_with_default "device name" "")
        export DEVICE_NAME
    fi
}


function prompt_with_default() {
  local prompt="$1"
  local default_value="$2"
  local user_input

  while true; do
    read -p "$prompt [$default_value]: " user_input

    if [ -z "$user_input" ]; then
      user_input="$default_value"
    fi

    if [ -n "$user_input" ]; then
      break
    else
      echo "Value cannot be empty. Please enter a value."
    fi
  done

  echo "$user_input"
}



function createSupervisorScript() {
    installScript='

startHoneygain() {
    container_name=honeygain
    if docker container inspect "$container_name" >/dev/null 2>&1; then docker rm -f $container_name; fi;

    docker run --privileged --rm tonistiigi/binfmt --install amd64

    docker run -d \
    --name honeygain \
    --restart unless-stopped \
    --label=com.centurylinklabs.watchtower.enable=true \
    --platform=linux/amd64 \
    honeygain/honeygain \
    -tou-accept \
    -email '"$ACCOUNT_EMAIL"' \
    -pass '"$ACCOUNT_PASSWORD"' \
    -device '"$DEVICE_NAME"'
}

run() {
    echo "starting honeygain"
    startHoneygain

    while true; do
        sleep 3600
    done
}

run
'

 echo "$installScript" > $honeygainFolder/honeygain-supervisor.sh
}

function startSupervisor(){
    container_name=honeygain-supervisor
    if $hypervisor container inspect "$container_name" >/dev/null 2>&1; then $hypervisor rm -f $container_name; fi;

    $hypervisor run -d --restart unless-stopped --name $container_name \
        -v /var/run/$hypervisor.sock:/var/run/docker.sock \
        -v $honeygainFolder/honeygain-supervisor.sh:/run.sh \
        --label=com.centurylinklabs.watchtower.enable=true \
        docker sh -c "sh /run.sh"
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

echo "Starting honeygain installation"
echo "(you can run this script multiple times without any issue)"

hypervisor=$(checkBalenaDocker)

createFolders
onBoardHoneygain
createSupervisorScript
startSupervisor
displayQr
echo "finished"
