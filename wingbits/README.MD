# Wingbits

[Wingbits Website](https://wingbits.com/)  
[Wingbits Discord](https://discord.com/invite/ZmpRW73qRH)  

## Prerequisites

### On nebra and sensecap

none, everything is ready

### On default raspberry pi os (Pisces P100)
```shell
sudo apt install uuid-runtime
```

## Installation

On nebra and sensecap:

```shell
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh')"
```

Other devices
```shell
sudo mkdir /mnt/data
sudo bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh')"
```

## Information

While installing, you will be asked to:
- generate any [random UUID](https://www.uuidgenerator.net/)
- get your location using [Google Earth](https://earth.google.com/web/)'s url
- get your time zone, from [wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

Want to customize the settings ?  
- [Full doc](https://github.com/sdr-enthusiasts/docker-adsb-ultrafeeder)
- files:
  - /mnt/data/depin/ultrafeeder/ultrafeeder-data.txt
