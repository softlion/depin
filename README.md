# Welcome !

This repo holds scripts to mine or dual mine. It works on linux devices, like Helium hotspots or raspberry pi.

THIS GITHUB REPO IS NOT AFFILIATED WITH ANY COMPANY.

It is built on my spare time.

# Projects

🚨  
🚨 Any project can be a SCAM or a PONZI. Do your own research.  
🚨 Start by reading [how to detect a SCAM](https://www.investopedia.com/articles/forex/042315/beware-these-five-bitcoin-scams.asp)  
🚨 In a PONZI, newcomers "pay" for the ones who are already in the project.  
🚨 Beware that having a free hosted `mongodb` is not a proof of existence. And if it does not exist, then you know it's a ponzi.  
🚨  

[List of DePIN projects, with study of their profitability](https://wholovesburrito.com/project-list/)

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

sudo docker run --rm --volume "/var/run/docker.sock":/var/run/docker.sock containrrr/watchtower --label-enable --run-once
```


# Tip

* Star the project (tap on the start on top right)

* Donate if those scripts helped you !  

Multi chain Metamask account (BSC, Etherum, Arbitrum, Doge, Polygon, Avalanche, ...):

0xe0018e74856e68A62d142Ab1C77b0F7B0ca3a2Ea

![image](https://github.com/softlion/defli/assets/190756/9d4f1589-5f7f-46f4-ae0d-1190d2e22762)
