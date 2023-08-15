#wingbits install on docker/balena
#github.com/softlion/depin

#create folders
depinFolder=/mnt/data/depin;
folder=$depinFolder
if [ ! -d $folder ]; then mkdir -p $folder; fi;

ultrafeederFolder=/mnt/data/depin/ultrafeeder;
folder=$ultrafeederFolder
if [ ! -d $folder ]; then mkdir -p $folder; fi;

ultrafeederDataFile="$ultrafeederFolder/ultrafeeder-data.txt"


function installWingbits() {

    #create folders
    wingbitsFolder=$depinFolder/wingbits;
    folder=$wingbitsFolder
    if [ ! -d $folder ]; then mkdir -p $folder; fi;


    if [ -z "$DEVICEID" ]; then    
        echo "Enter your Wingbits Device ID (your-wingbits-id)"
        DEVICEID=$(prompt_with_default "Winbits ID" "")
    fi

    response=$(curl -o $wingbitsFolder/vector.toml --write-out "%{http_code}" 'https://gitlab.com/wingbits/config/-/raw/master/vector.toml')
    if [ "$response" -ne 200 ]; then
        echo "can not download from gitlab: HTTP error code $response"
        exit 1
    fi

    sed -i 's/0.0.0.0:30006/0.0.0.0:30099/g' $wingbitsFolder/vector.toml;


    if ! $hypervisor network inspect adsbnet >/dev/null 2>&1; then 
        $hypervisor network create adsbnet; 
    fi;
    removeContainer ultrafeeder
    removeContainer vector


    #start VMs
    #expose tar1090 webui on 8080 on the host
    $hypervisor run -d --name ultrafeeder --hostname ultrafeeder \
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
        ghcr.io/sdr-enthusiasts/docker-adsb-ultrafeeder;


    #receives data from ultrafeeder (see ultrafeederDataFile)
    #tranform that data and transmit it to wingbits
    $hypervisor run -d --name vector \
        --restart unless-stopped \
        --network=adsbnet \
        -e DEVICE_ID="$DEVICEID" \
        -v $wingbitsFolder/vector.toml:/etc/vector/vector.toml:ro \
        --label=com.centurylinklabs.watchtower.enable=true \
        timberio/vector:latest-alpine;
}


function askUltrafeederStationData() {

    #Get USB bus and device numbers of the RTL stick
    deviceNameQuery='RTL2838|ADSB_1090'
    line=$(lsusb | grep -E $deviceNameQuery)
    
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

        #overwrite the file with a new version if one exists
        response=$(curl -o "$ultrafeederDataFile" --write-out "%{http_code}" 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/ultrafeeder-data.txt')
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


    if [ -z "$stationUuid" ]; then
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
    echo "Open Google Earth, center on the location of your antenna."
    echo "The URL will look like @37.13445868,7.96957148,207.72258715a,...."
    echo "The 1st number is the latitude, the 2nd the longitude and the 3rd the altitude from sea level in meters (207.72258715)."

    latitude=$(prompt_with_default "Latitude" "$latitude")
    longitude=$(prompt_with_default "Longitude" "$longitude")
    altitudeMeters=$(prompt_with_default "Altitude (in meters)" "$altitudeMeters")
    altitudeFeet=$(echo "$altitudeMeters * 3.28084" | bc)

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

    if $hypervisor container inspect "$container_name" >/dev/null 2>&1; then
        echo "Removing container $containerName";
        $hypervisor rm -f $container_name;
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


hypervisor=$(checkBalenaDocker)
askUltrafeederStationData
installWingbits
displayQr
echo "finished"
