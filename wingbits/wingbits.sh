#wingbits install on docker/balena
#github.com/softlion/depin 

function installWingbits() {

    #Validate OS
    case "$(uname -s)" in Linux) GOOS="linux" ;; Darwin) GOOS="darwin" ;; *) echo "Unsupported OS" && exit 3 ;; esac
    case "$(uname -m)" in x86_64) GOARCH="amd64" ;; i386|i686) GOARCH="386" ;; armv7l) GOARCH="arm" ;; aarch64|arm64) GOARCH="arm64" ;; *) echo "Unsupported architecture" && exit 4 ;; esac

    wingbitsFolder="$projectFolder";
    stationFile="$wingbitsFolder/station.txt"

    #Get station id
    if [ -z "$DEVICEID" ]; then
        if [ "$($runHypervisor inspect -f '{{.State.Running}}' vector 2>/dev/null)" = "true" ]; then
            DEVICEID=$($hypervisor exec "vector" sh -c 'echo $DEVICE_ID')
        fi

        if [ -z "$DEVICEID" ] && [ -f "$stationFile" ]; then
            DEVICEID=$(cat $stationFile)
        fi

        echo "If this is a new station, register it first at https://wingbits.com/dashboard/stations"
        echo "and write down its ID (the ID has 3 words, it looks like 'macho-cider-storm')"
        while true; do
            echo "Enter the Station ID registered in WingBits:"
            DEVICEID=$(prompt_with_default "Wingbits Station ID" "$DEVICEID")
            if [[ $DEVICEID =~ ^[a-z]+-[a-z]+-[a-z]+$ ]]; then
                break
            else
                echo -e "The Station ID is not properly formatted. Must be 3 words separated by hyphens. Ex: 'abc-def-ghi'"
                DEVICEID=""
            fi
        done
    fi

    #Store station id
    if [ -n "$DEVICEID" ]; then
        echo "$DEVICEID" > "$stationFile"
        echo "Using Wingbits Station ID: $DEVICEID"
    else
        echo "No Station ID set. It is mandatory. Stopping."
        exit 2;
    fi

    if ! $runHypervisor network inspect adsbnet >/dev/null 2>&1; then 
        $runHypervisor network create adsbnet; 
    fi;
    removeContainer ultrafeeder
    removeContainer vector
    removeContainer wingbits


    #start containers

    #Container: ultrafeeder
    #expose tar1090 webui on 8080 on the host
    #9273-9274:9273-9274 # to expose the statistics interface to Prometheus
    $runHypervisor run -d --name ultrafeeder --hostname ultrafeeder \
        --restart unless-stopped \
        --network=adsbnet \
        --env-file $ultrafeederDataFile \
        -p 8080:80 \
        --device-cgroup-rule 'c 189:* rwm' \
        -v $ultrafeederFolder/globe_history:/var/globe_history \
        -v $ultrafeederFolder/graphs1090:/var/lib/collectd \
        -v /proc/diskstats:/proc/diskstats:ro \
        -v /dev:/dev:ro \
        --tmpfs /run:exec,size=256M \
        --tmpfs /tmp:size=128M \
        --tmpfs /var/log:size=32M \
        --label=com.centurylinklabs.watchtower.enable=true \
        "ghcr.io/sdr-enthusiasts/docker-adsb-ultrafeeder:telegraf-build-641";


    #Container: wingbits
    #receives data from ultrafeeder (see ultrafeederDataFile)
    #reads data from the secure GPS (geosigner)
    #transform that data and transmit it to wingbits

    #-p 30006:30006 vapolia/wingbits:latest-amd64

    # Check if the secure GPS is present
    MAP_SECURE_GPS=""
    if [ -e /dev/ttyACM0 ]; then
      MAP_SECURE_GPS="--device=/dev/ttyACM0:/dev/ttyACM0"
      echo "Geosigner (secure GPS) found"
    else
      echo "Geosigner (secure GPS) NOT FOUND. It is required to receive wingbits rewards."
    fi
    
    $runHypervisor run -d --name wingbits \
        --restart unless-stopped \
        --network=adsbnet \
        -v "$stationFile:/etc/wingbits/device:ro" \
        $MAP_SECURE_GPS \
        -p 30006:30006 \
        --label=com.centurylinklabs.watchtower.enable=true \
        "vapolia/wingbits:latest";
}


function askUltrafeederStationData() {

    #Get USB bus and device numbers of the RTL stick
    deviceNameQuery='RTL2838|ADSB_1090|0bda:2838'
    set +e
    line=$(lsusb | grep -E $deviceNameQuery)
    set -e
    
    if [ -z "$line" ]; then
        echo "No RTL-SDR stick found (searching $deviceNameQuery)"
        exit 1
    fi

    rtlCount=$(echo $line | grep -Ec $deviceNameQuery)
    if [ "$rtlCount" -gt 1 ]; then
        echo "More than one RTL-SDR stick found. Not currently supported by this script."
        exit 2
    fi

    bus_number=$(echo "$line" | cut -d ' ' -f 2)
    device_number=$(echo "$line" | cut -d ' ' -f 4 | cut -d ':' -f 1)
    stationName=""
    stationUuid=""
    latitude=""
    longitude=""
    altitudeMeters=""
    timezone=""
    gain="default"

    
    #Get the data files
    if ! [ -f "$ultrafeederDataFile" ]; then
        response=$(curl -o "$ultrafeederDataFile" --write-out "%{http_code}" 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/ultrafeeder-data.txt')
        if [ "$response" -ne 200 ]; then
            echo "can not download ultrafeeder-data.txt from softlion/depin github: HTTP error code $response"
            exit 3
        fi
    else
        stationName=$(get_value "FEEDER_NAME")
        stationUuid=$(get_value "ULTRAFEEDER_UUID")
        latitude=$(get_value "FEEDER_LAT")
        longitude=$(get_value "FEEDER_LONG")
        altitudeMeters=$(get_value "FEEDER_ALT_M")
        timezone=$(get_value "FEEDER_TZ")
        gain=$(get_value "READSB_GAIN")
        gain=${gain:-default}
    fi

    zonefile="$ultrafeederFolder/zone1970.tab"
    if ! [ -f "$zonefile" ]; then
        response=$(curl -o $zonefile --write-out "%{http_code}" 'https://raw.githubusercontent.com/eggert/tz/main/zone1970.tab')
        if [ "$response" -ne 200 ]; then
            echo "can not download zone1970.tab from github: HTTP error code $response"
            exit 3
        fi
    fi

    #Update the template content with required fields
    echo "Choose a name for this station"
    echo "Do not use special chars"
    stationName=$(prompt_with_default "Station Name" "$stationName")


    if [ -z "$stationUuid" ] || ! is_valid_guid "$stationUuid"; then
        stationUuid=$(uuidgen)
    fi
    while true; do
        stationUuid=$(prompt_with_default "Station UUID" "$stationUuid")
        if is_valid_guid "$stationUuid"; then
            break;
        fi
        echo "Invalid UUID. Make sure the format is b2b2b2b2-1111-2222-3333-4c4c4c4c4c4c with only A-E/a-e/0-9"
    done

    echo "Latitude, Longitude and Altitude from sea level of this station in meters"
    echo "can be found on google earth https://earth.google.com/"
    echo "Open Google Earth, center on the location of your station."
    echo "The URL will look like @37.13445868,7.96957148,207.72258715a,...."
    echo "The 1st number is the latitude, the 2nd the longitude and the 3rd the altitude from sea level in meters (207.72258715)."

    latitude=$(prompt_with_default "Latitude" "$latitude")
    longitude=$(prompt_with_default "Longitude" "$longitude")
    altitudeMeters=$(prompt_with_default "Altitude (in meters)" "$altitudeMeters")
    altitudeFeet=$((altitudeMeters * 328084 / 100000))

    echo "Select your timezone"
    echo "Enter the value of the TZ Identifier column of this table:"
    echo "https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
    mapfile -t existingTimezones < <(cut -f 3 "$zonefile")
    while true; do
        timezone=$(prompt_with_default "TimeZone" "$timezone")
        if [[ " ${existingTimezones[*]} " == *" $timezone "* ]]; then
            break;
        fi
        echo "Invalid time zone selection. Please choose from the list above."
    done

    #Since november 2024, a new autogain alg is used when the gain is NOT set.
    #It is recommended to leave this parameter commented out.
    #Source: https://github.com/sdr-enthusiasts/docker-adsb-ultrafeeder?tab=readme-ov-file#using-readsbs-built-in-autogain-recommended
    #If you still want to set this value, see https://github.com/wiedehopf/readsb?tab=readme-ov-file#autogain
    echo "Enter a gain"
    echo "Read more on see https://github.com/wiedehopf/readsb?tab=readme-ov-file#autogain and https://github.com/sdr-enthusiasts/docker-adsb-ultrafeeder?tab=readme-ov-file#using-readsbs-built-in-autogain-recommended"
    echo "Possible values: 0-255 | default | autogain | off"
    echo "Recommended value: default (or 39 if you don't want auto gain)"
    gain=$(prompt_with_default "Gain" "$gain")

    #overwrite the file with a new version if one exists
    response=$(curl -o "$ultrafeederDataFile" --write-out "%{http_code}" 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/ultrafeeder-data.txt')

    #replace data by user value
    sed -i "s/^FEEDER_NAME=.*/FEEDER_NAME=$stationName/" $ultrafeederDataFile
    sed -i "s/^ULTRAFEEDER_UUID=.*/ULTRAFEEDER_UUID=$stationUuid/" $ultrafeederDataFile
    sed -i "s/^FEEDER_LAT=.*/FEEDER_LAT=$latitude/" $ultrafeederDataFile
    sed -i "s/^FEEDER_LONG=.*/FEEDER_LONG=$longitude/" $ultrafeederDataFile
    sed -i "s/^FEEDER_ALT_M=.*/FEEDER_ALT_M=$altitudeMeters/" $ultrafeederDataFile
    sed -i "s/^FEEDER_ALT_FT=.*/FEEDER_ALT_FT=$altitudeFeet/" $ultrafeederDataFile
    sed -i "s|^FEEDER_TZ=.*|FEEDER_TZ=$timezone|" "$ultrafeederDataFile"
    sed -i "s|/dev/bus/usb/[0-9]*/[0-9]*|/dev/bus/usb/$bus_number/$device_number|" $ultrafeederDataFile

    sed -i "s/^TAR1090_DEFAULTCENTERLAT=.*/TAR1090_DEFAULTCENTERLAT=$latitude/" $ultrafeederDataFile
    sed -i "s/^TAR1090_DEFAULTCENTERLON=.*/TAR1090_DEFAULTCENTERLON=$longitude/" $ultrafeederDataFile
    sed -i "s/^TAR1090_PAGETITLE=.*/TAR1090_PAGETITLE=$stationName/" $ultrafeederDataFile

    sed -i "s/^READSB_LAT=.*/READSB_LAT=$latitude/" $ultrafeederDataFile
    sed -i "s/^READSB_LON=.*/READSB_LON=$longitude/" $ultrafeederDataFile
    sed -i "s/^READSB_ALT=.*/READSB_ALT=$altitudeMeters/" $ultrafeederDataFile

    if [ "$gain" = "default" ]; then
        sed -i "/^READSB_GAIN=/d" "$ultrafeederDataFile"
    else
        sed -i "s/^READSB_GAIN=.*/READSB_GAIN=$gain/" $ultrafeederDataFile
    fi

    echo ""
    echo "Summary:"
    echo "Station Name: $stationName"
    echo "Lat/Lon/Alt: $latitude / $longitude / $altitudeMeters"
    echo "TimeZone: $timezone"
    echo "RTL-SDR port: /dev/bus/usb/$bus_number/$device_number"
    echo ""
}


function removeContainer(){
    local container_name=$1

    if $runHypervisor container inspect "$container_name" >/dev/null 2>&1; then
        echo "Removing container $containerName";
        $runHypervisor rm -f $container_name;
    fi
}

function createProjectFolder(){
    local projectRelativeFolder="$1"
    local mod="${2:-775}"

    depinFolder=$([ "$hypervisor" == "balena" ] && echo "/mnt/data/depin" || echo "/usr/src/depin")
    local projectFolder="$depinFolder/$projectRelativeFolder";

    folder="$projectFolder"
    if [ ! -d "$folder" ]; then 
        if [ "$hypervisor" = "balena" ]; then
            mkdir -p "$folder";

            chown $(whoami):sudo "$folder"
            chmod "$mod" "$folder"
        else
            sudo mkdir -p "$folder";

            sudo chown $(whoami):sudo "$folder"
            sudo chmod "$mod" "$folder"
        fi
    fi;

    echo "$projectFolder"
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

function is_valid_guid() {
  local input=$1
  local guid_pattern='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
  if [[ $input =~ $guid_pattern ]]; then return 0; else return 1; fi
}

function get_value() {
  local key="$1"
  local value=$(awk -F '=' '/^'"$key"'/ {print $2}' "$ultrafeederDataFile")
  echo "$value"
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

echo "Installing containers to run a wingbit node on balena or docker"
echo "(you can run this script multiple times without any issue)"

set -e
set -o pipefail

hypervisor=$(checkBalenaDocker)
runHypervisor="$([[ "$hypervisor" == "docker" ]] && echo 'sudo docker' || echo 'balena')"
echo "Using hypervisor $hypervisor and run $runHypervisor"
projectFolder=$(createProjectFolder "wingbits")
ultrafeederFolder=$(createProjectFolder "ultrafeeder")
ultrafeederDataFile="$ultrafeederFolder/ultrafeeder-data.txt"
askUltrafeederStationData
installWingbits
displayQr
echo "finished"
