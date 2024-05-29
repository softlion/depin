# Welcome !

This repo holds scripts to mine or dual mine. It works on linux devices, like Helium hotspots or raspberry pi.

THIS GITHUB REPO IS NOT AFFILIATED WITH ANY COMPANY.

# Projects

[List of DePIN projects, with study of their profitability](https://wholovesburrito.com/top-roi-project-rank/)


# Scripts

Open the folder you are interested in, and follow the instructions there.

#  Details Common to all Scripts

The `.ps1` scripts are for Windows machines. They will connect using ssh to the given device IP, and executes the `.sh` script.  Instead you can run the ".sh" script directly from a ssh session on the target device.

The scripts support both balena and docker, so they can run on Pisces, Sensecap, Nebra, and other Raspberry PI devices having docker or balena installed. It will create configuration folders in /mnt/data/ or /usr/depin though.

The scripts will ask you all required info for onboarding.  
You can also run the scripts multiple times.

## From Windows
- Install the latest version of [microsoft powershell](https://www.microsoft.com/store/productId/9MZ1SNWT0N5D) from the windows store.
- open powershell (enter `pwsh` in the search box of the window's taskbar)
```powershell
pwsh -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/softlion/depin/main/zzzzzzzzzz.ps1' | iex"
```

Replace `zzzzzzzzzz` by one of the existing file name.

Ex:
```
pwsh -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.ps1' | iex"
```

## Directly from within the device
- ssh into your device and run:
```shell
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/.../zzzzzzzzzz.sh')"
#or
sudo bash ...
```

Replace `zzzzzzzzzz` by one of the existing file name.

Ex:
```
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh')"
#or
sudo bash ...
```

# Automatic Updates

To update the containers automatically, use watchtower.

All nebra firmwares, Sensecap:
```
balena run -d --restart unless-stopped \
      --name watchtower \
      --volume "/var/run/balena.sock":/var/run/docker.sock \
      --label=com.centurylinklabs.watchtower.enable=true \
      containrrr/watchtower \
      --label-enable

balena run --rm --volume "/var/run/balena.sock":/var/run/docker.sock  containrrr/watchtower --label-enable --run-once
```

Pisces P100, other devices:
```
sudo docker run -d --restart unless-stopped \
      --name watchtower \
      --volume "/var/run/docker.sock":/var/run/docker.sock \
      --label=com.centurylinklabs.watchtower.enable=true \
      containrrr/watchtower \
      --label-enable

nohup sudo docker run --rm --volume "/var/run/docker.sock":/var/run/docker.sock containrrr/watchtower --label-enable --run-once
```

## Cleaning disk space

Auto updating is nice, but it downloads new versions without deleting the old inactive ones.  
To delete the old inactive versions and reclaim disk space run:

`sudo docker image prune -a`
or
`balena image prune -a`

# Tip

* Star the project (tap on the start on top right)

* Donate if those scripts helped you !  

Multi chain Metamask account (BSC, Etherum, Arbitrum, Doge, Polygon, Avalanche, ...):

0xe0018e74856e68A62d142Ab1C77b0F7B0ca3a2Ea

![Alt](https://repobeats.axiom.co/api/embed/f686d24040945f6ddde231208e2a4d5ae0f79466.svg "Repobeats analytics image")
