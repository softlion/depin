# ThingsIX

[Web site](https://thingsix.com/)  
[Explorer](https://app.thingsix.com/)

# Install

This script is for original `nebra` or `sensecap` devices (ie: any device using `balena`).  
It will be updated shortly to include any deving using `docker` like `Pisces`.

From Windows:

```powershell
.\thingsIX.ps1 192.168.10.20
```

(replace the IP by your device IP)

# Install steps

The script will make sure the existing helium miner software is partially replaced by a lorawan multiplexer, even when you reboot or when it is updated by nebra/sensecap remotely.  
So you will receive rewards from both thingsIX and Helium.
