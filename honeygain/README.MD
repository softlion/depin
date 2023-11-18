# Honeygain

[Honeygain Website](https://r.honeygain.me/BENJAA3957)  

## Installation

First, [create an account](https://r.honeygain.me/BENJAA3957).

Then execute one of the script below in a ssh session on your device.  
Replace:
* ACCOUNT_EMAIL: your honeygain login
* ACCOUNT_PASSWORD: your honeygain password 
* DEVICE_NAME: by anything you want, it will be displayed on honeygain dashboard


On nebra and sensecap:

```shell
balena run --privileged --rm tonistiigi/binfmt --install amd64

balena run -d \
  --name honeygain \
  --restart unless-stopped \
  --label=com.centurylinklabs.watchtower.enable=true \
  --platform=linux/amd64 \
  honeygain/honeygain \
  -tou-accept \
  -email ACCOUNT_EMAIL \
  -pass ACCOUNT_PASSWORD \
  -device DEVICE_NAME
```

Other raspberry pi devices (Pisces P100, ...):
```shell
sudo docker run --privileged --rm tonistiigi/binfmt --install amd64

sudo docker run -d \
  --name honeygain \
  --restart unless-stopped \
  --label=com.centurylinklabs.watchtower.enable=true \
  --platform=linux/amd64 \
  honeygain/honeygain \
  -tou-accept \
  -email ACCOUNT_EMAIL \
  -pass ACCOUNT_PASSWORD \
  -device DEVICE_NAME
```

# Tip

* Star the project ! Tap on the star on the top right of this screen.

* Donate something !
  * That let me know I should continue 
  * EVM wallet: 0xe0018e74856e68A62d142Ab1C77b0F7B0ca3a2Ea

![image](https://github.com/softlion/defli/assets/190756/9d4f1589-5f7f-46f4-ae0d-1190d2e22762)
