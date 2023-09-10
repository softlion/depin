 
function installPresearch(){
    if [ -z "$REGISTRATION_CODE" ]; then
        echo "Enter your node registration code from"
        echo "https://nodes.presearch.com/dashboard"
        REGISTRATION_CODE=$(prompt_with_default "Node registration code" "")
    fi

    container="presearch"
    if $runHypervisor container inspect "$container" >/dev/null 2>&1; then $runHypervisor rm -f "$container"; fi;

    $runHypervisor run -dt --name "$container" \
      --restart=unless-stopped \
      -v "$projectFolder":/app/node \
      --label=com.centurylinklabs.watchtower.enable=true \
      -e REGISTRATION_CODE="$REGISTRATION_CODE" \
      presearch/node; 
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
            sudo chown -R $(whoami) "$folder"
            chmod -R u+rw "$folder"
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

echo "Starting Presearch installation"
echo "(you can run this script multiple times)"

hypervisor=$(checkBalenaDocker)
runHypervisor="$([[ "$hypervisor" == "docker" ]] && echo 'sudo docker' || echo 'balena')"
createProjectFolder "presearch"
installWatchTower
installPresearch
displayQr
echo "finished"
echo "validation: "
echo "$runHypervisor logs -f $container"
