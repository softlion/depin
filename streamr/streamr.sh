dockerContainer="streamr/broker-node:testnet-one"

function installStreamr() {

  echo "Checking containers"
  container="streamr"
  if $runHypervisor container inspect "$container" >/dev/null 2>&1; then $runHypervisor rm -f "$container"; fi;


  startConfigWizard=true
  if [ -e "$projectFolder/config/default.json" ]; then
    echo "A configuration file already exists."
    result=$(prompt_with_default "Rerun the configuration wizard? (y/n)" "n")
    [ "$result" != "y" ] && startConfigWizard=false;
  fi

  if [ "$startConfigWizard" = true ]; then
    echo "Starting configuration wizard"
    #  --user "$(id -u):$(id -g)" \
    $runHypervisor run -it \
      -v "$projectFolder":/home/streamr/.streamr \
      -v "$projectFolder":/root/.streamr \
      "$dockerContainer" \
      bin/config-wizard;

    if [ "$hypervisor" = "balena" ]; then
        chmod 664 "$projectFolder/config/default.json"
    else
        sudo chmod 664 "$projectFolder/config/default.json"
        sudo chmod 775 "$folder/config"
    fi
  fi

  #start node
  echo "Starting node"
  $runHypervisor run -d --name "$container" \
    --restart unless-stopped \
    -p 32200:32200 \
    -v "$projectFolder":/home/streamr/.streamr \
    -v "$projectFolder":/root/.streamr \
    --label=com.centurylinklabs.watchtower.enable=true \
    "$dockerContainer";
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
            mkdir -p "$folder/config";

            chown $(whoami):sudo "$folder"
            chmod 775 "$folder"
            chown $(whoami):sudo "$folder/config"
            chmod 777 "$folder/config"
        else
            sudo mkdir -p "$folder/config";

            sudo chown $(whoami):sudo "$folder"
            sudo chmod 775 "$folder"

            sudo chown $(whoami):sudo "$folder/config"
            sudo chmod 777 "$folder/config"
        fi

        echo "done creating"
    fi;
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

function installWatchTower() {

  #install watchtower
  echo "Checking Watchtower"
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

echo "Installing a container to run a streamr node on balena or docker"
echo "(you can run this script multiple times without any issue)"

set -e
set -o pipefail

hypervisor=$(checkBalenaDocker)
runHypervisor="$([[ "$hypervisor" == "docker" ]] && echo 'sudo docker' || echo 'balena')"
echo "Using hypervisor $hypervisor and run $runHypervisor"
createProjectFolder "streamr"
installWatchTower
installStreamr
displayQr
echo "finished. Validation: "
echo "$runHypervisor logs -f $container"
echo "Note the node PUBLIC key above and add it to https://mumbai.streamr.network/hub/network/operators"
echo "see https://docs.streamr.network/guides/become-an-operator/"
echo "Also open and forward port 32200 on your router to this machine"
