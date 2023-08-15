# Welcome !

This repo holds scripts to mine or dual mine. It works on linux devices, like Helium hotspots or raspberry pi.

THIS GITHUB REPO IS NOT AFFILIATED WITH ANY COMPANY.

It is built on my spare time.

# Projects

🚨  
🚨 Any project can be a SCAM or a PONZI. Do you own research.  
🚨 Start by reading [how to detect a SCAM](https://www.investopedia.com/articles/forex/042315/beware-these-five-bitcoin-scams.asp)  
🚨 In a PONZI, newcomers "pay" for the ones who are already in the project.  
🚨  

[Wingbits Website](https://wingbits.com/)  
[Wingbits Discord](https://discord.com/invite/ZmpRW73qRH)  

[List of other DePIN projects](https://wholovesburrito.com/project-list/)

# Scripts

The `.ps1` scripts for windows machines will ssh to the given IP and executes the `.sh` script on it.  Instead you can run the ".sh" script directly from a ssh session on the target device.

It supports both balena and docker, so it can run on Pisces, Sensecap, Nebra, and other Raspberry PI devices having docker or balena installed. It will create configuration folders in /mnt/data/ though.

The scripts will ask you all required info for onboarding. You can run the script multiple times, for example to change the location of elevation.

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
curl https://raw.githubusercontent.com/softlion/depin/main/zzzzzzzzzz.sh | sudo bash
```

Replace `zzzzzzzzzz` by one of the existing file name.

Ex:
```
curl https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh | sudo bash
```

# Tip

Donate for a coffee if that script helped you !  
I'd love to visit new countries in the world.

Multi chain Metamask account (BSC, Etherum, Arbitrum, Doge, Polygon, Avalanche, ...):

0xe0018e74856e68A62d142Ab1C77b0F7B0ca3a2Ea

![image](https://github.com/softlion/defli/assets/190756/9d4f1589-5f7f-46f4-ae0d-1190d2e22762)
