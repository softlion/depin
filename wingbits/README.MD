# Wingbits

[Wingbits Website](https://wingbits.com/)  
[Wingbits Discord](https://discord.com/invite/ZmpRW73qRH)  

## News

2025-02-02:
Geosigner support. The installation script for diy stations has been updated to support the new wingbits client and the geosigner.  
It uses the new container https://hub.docker.com/r/vapolia/wingbits, built with a github action from this git repository.

2024-11-21: 
Do-It-Yourself Wingbit stations are not more allowed, and all GeoSigner devices for existing stations have been assigned.  
You can't build a Wingbit station with a custom hardware anymore.  

That means this script is only useful to update your existing installation.  
It is useless for everyone else.

# CAN'T BE USED ANYMORE TO BUILD A NEW WINGBIT STATION

You can buy [official Wingbits stations there]( https://docs.wingbits.com/project/wingbits-approved-distributors) for example.

## Prerequisites

### On nebra and sensecap

none, everything is ready

### On default raspberry pi os (Pisces P100)
```shell
sudo apt install -y uuid-runtime
```
Also make sure you have the latest version of docker. On Pisces P100 you will have to uninstall docker first, as it was installed using an unofficial installer. Use the universal uninstaller on the official docker website. On my side, I wiped the OS and installed the latest rpi distribution to get the latest security changes. But that requires more advanced knowledge.

## Installation

On nebra and sensecap (balena OS):

```shell
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh')"
```

Other devices (linux):
```shell
sudo bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh')"
```

After installation, browse to:
- `http://device-ip-address:8080/` to display the live map
- `http://device-ip-address:8080/?heatmap` to display the heat map
- `http://device-ip-address:8080/graphs1090` to display the stats page




## Update

Rerun the installation script.  
It should remember your last settings, press enter to accept them.

## Information

While installing, you will be asked to:
- generate any [random UUID](https://www.uuidgenerator.net/)
- get your location using [Google Earth](https://earth.google.com/web/)'s url
- get your time zone, from [wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

Want to customize the settings ?  
- [Full doc](https://github.com/sdr-enthusiasts/docker-adsb-ultrafeeder)
- file:
  - Sensecap/nebra: `nano /mnt/data/depin/ultrafeeder/ultrafeeder-data.txt`
  - Other: `sudo nano /usr/src/depin/ultrafeeder/ultrafeeder-data.txt`
- restart the ultrafeeder container after changing those settings
  - Sensecap/nebra: `balena restart ultrafeeder`
  - Other: `sudo docker restart ultrafeeder`
- check the logs
  - Sensecap/nebra: `balena logs -f ultrafeeder` to see what adsb parameters it used
  - Other: `sudo docker logs -f ultrafeeder` to see what adsb parameters it used

## Gain

While installing, it will ask you for the gain you want.

You can choose between `default` (recommanded), `autogain` (not recommended), a value (`39`) or a list of values.  
For a list of values, check the (doc here)[https://github.com/wiedehopf/readsb?tab=readme-ov-file#autogain].  
For example: `auto-verbose,0,25,31,243`

Verifying:

- check out the logs `sudo docker logs -f ultrafeeder` or `balena logs -f ultrafeeder` and search for the readsb command line.
- check out the "Misc" graph on 'http://<ip>:8080/graphs1090', the current gain is written below that graph.

## GeoSigner

Check the logs:
```
sudo docker logs -f wingbits
#or
balena logs -f wingbits
```

Check the number of satellites:
```
sudo docker exec wingbits wingbits geosigner info
#or
balena exec wingbits wingbits geosigner info
```

# Other links

- [official Wingbits stations there](https://docs.wingbits.com/project/wingbits-approved-distributors)
- [This one has good prices in EU](https://crypship.io/en/product/wingbits-wb300/)
