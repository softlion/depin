# Wingbits

[Wingbits Website](https://wingbits.com/)  
[Wingbits Discord](https://discord.com/invite/ZmpRW73qRH)  

## News

2024-05-24: update your wingbits installation in the next 15 days to continue receiving rewards.  
            Simply rerun this script to update.

## Prerequisites

### On nebra and sensecap

none, everything is ready

### On default raspberry pi os (Pisces P100)
```shell
sudo apt install -y uuid-runtime
```

## Installation

On nebra and sensecap:

```shell
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh')"
```

Other devices
```shell
sudo bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh')"
```

After installation  
Browse to:
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

## Auto gain
```
balena exec ultrafeeder /usr/local/bin/autogain1090
```
or
```
sudo docker exec ultrafeeder /usr/local/bin/autogain1090
```
