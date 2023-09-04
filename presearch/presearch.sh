 
function createFolders(){
    echo "Creating folders"
    depinFolder=$([ "$hypervisor" == "balena" ] && echo "/mnt/data/depin" || echo "/usr/src/depin")

    folder="$depinFolder"
    if [ ! -d "$folder" ]; then 
        echo "creating $folder"

        if [ "$hypervisor" = "balena" ]; then
            mkdir -p "$folder";
        else
            sudo mkdir -p "$folder";
            sudo chown -R $(whoami) "$folder"
            chmod -R u+rw /usr/src/depin
        fi

        echo "done creating"
    fi;

    presearchFolder="$depinFolder/presearch";
    folder="$presearchFolder"
    if [ ! -d $folder ]; then mkdir -p "$folder"; fi;
}

function installPresearch(){
    if [ -z "$REGISTRATION_CODE" ]; then
        echo "Enter your node registration code from"
        echo "https://nodes.presearch.com/dashboard"
        REGISTRATION_CODE=$(prompt_with_default "Node registration code" "")
    fi

    container_name="presearch"
    if $hypervisor container inspect "$container_name" >/dev/null 2>&1; then $hypervisor rm -f "$container_name"; fi;

    docker run -dt --name "$container_name" \
    --restart=unless-stopped \
    -v "$presearchFolder":/app/node \
    --label=com.centurylinklabs.watchtower.enable=true \
    -e REGISTRATION_CODE="$REGISTRATION_CODE" \
    presearch/node; 
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
  watchtowerContainerID=$($hypervisor ps -aqf name="watchtower")
  if [ -z "$watchtowerContainerID" ]; then watchtowerInstalled=false; else watchtowerInstalled=true; fi

  if [[ ! $watchtowerInstalled ]]; then
    echo "Installing watchtower"

    $hypervisor run -d \
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
      echo "sudo docker"
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
createFolders
installWatchTower
installPresearch
displayQr
echo "finished"
echo "validation: "
echo "$hypervisor logs -f presearch"
