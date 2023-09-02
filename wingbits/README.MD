# Wingbits

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
