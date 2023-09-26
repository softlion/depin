# ThingsIX

Secure Lorawan Mining.

[Web site](https://thingsix.com/)  
[Explorer](https://app.thingsix.com/)

## Script

This script will make sure the existing helium miner software is partially replaced by a lorawan multiplexer, even when you reboot or when it is updated by nebra/sensecap remotely.  
So you will receive rewards from both thingsIX and Helium.

After the installation process, it will ask you to onboard your gateway. If you already onboarded the gateway the file `/mnt/data/depin/thingsix/forwarder/gateways.yaml` should already exist and you can stop the script (CTRL-C).

You can run this script multiple times.

note: to receive rewards for ThingsIX, your gateway must be mapped by a ThingsIX secure mapper.

## Installation

On `nebra` and `sensecap` devices (ie: any device using `balena`):

```shell
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/thingsix/thingsix.sh')"
```

Other raspberry pi devices with `docker` installed (including `pisces`):  
not yet released (already written and tested)

From Windows:
```powershell
pwsh -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/softlion/depin/main/thingsix/thingsix.ps1' | iex"
```

## Advanced

The windows script accept an optional ip address as argument:

```powershell
.\thingsIX.ps1 192.168.10.20
```

# Tip

* Star the project (tap on the start on top right)

* Donate if those scripts helped you !  

Multi chain Metamask account (BSC, Etherum, Arbitrum, Doge, Polygon, Avalanche, ...):

0xe0018e74856e68A62d142Ab1C77b0F7B0ca3a2Ea

![image](https://github.com/softlion/defli/assets/190756/9d4f1589-5f7f-46f4-ae0d-1190d2e22762)
