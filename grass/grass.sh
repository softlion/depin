#Grass docker/balena installer
#starts this container: grass (node)

function createFolders(){
    #create folders
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

    grassFolder=$depinFolder/grass;
    folder=$grassFolder
    if [ ! -d $folder ]; then mkdir -p $folder; fi;
}


function installGrass(){
    container_name=grass
    if $hypervisor container inspect "$container_name" >/dev/null 2>&1; then $hypervisor rm -f $container_name; fi;

    $hypervisor run -d --name $container_name \
        -v $grassFolder/grass.sh:/run.sh \
        --label=com.centurylinklabs.watchtower.enable=true \
        node sh -c "sh /run.sh"
}

function createGrassScript() {
    if [ -z "$userIds" ]; then    
        echo "Enter the user ids to associate with the IPs"
        userIds=$(prompt_with_default "Grass userIds" "")
    fi

    installScript='
function cleanup() {
    echo "Grass stopped"
    exit 0
}
trap cleanup SIGTERM


run() {
    echo "starting grass"
'+" user_ids_var="$userIds"
"+'
    #get source
    mkdir /usr/src/
    cd /usr/src/
    git clone https://github.com/Wynd-Network/grass-vps.git
    cd grass-vps

    #install
    apt install -y cron
    #chmod +x ./scripts/start.sh
    #echo "$user_ids_var" | ./scripts/start.sh
 
    LOCAL_DIR=$(pwd)
    cp "$LOCAL_DIR/.env.example" "$LOCAL_DIR/.env"
    sed -i "" "s/USER_IDS=/USER_IDS=$user_ids_var/g" $LOCAL_DIR/.env
    sed -i "" "s/NODE_ENV=/NODE_ENV=production/g" $LOCAL_DIR/.env

    npm install -g pm2
    npm install

    #run
    pm2 start $LOCAL_DIR/pm2.config.js
    echo It has now started! You can monitor the app using the "pm2 monit" command.

    # Add the update.sh file as a cron job
    crontab -l > vpscron
    echo "00 00 * * * $LOCAL_DIR/scripts/update.sh" >> vpscron
    crontab vpscron
    rm vpscron

    echo "Grass started"
    while true; do
        sleep 60  # Wait 60s
    done
}

run
'

  echo "$installScript" > $grassFolder/grass.sh
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

echo "Starting Grass installation"
echo "(you can run this script multiple times)"

hypervisor=$(checkBalenaDocker)
createFolders
createGrassScript
installGrass
displayQr
echo "finished"
