# Element Data
[ElementData Website](https://elementdata.xyz/)  
[ElementData Discord](https://discord.gg/ReZxN5W9Jw)  


## Installation

Follow the [instructions](https://elementdata.xyz/configuration)

You will need an `Awair Element` device for this project, or any other supported device.

## Additional FAQ

### How to get the Awair Element ID when you have multiple awairs in your cloud account?

1) On the Awair mobile app, tap on the device you want to get the id.  
   Then navigate to:  
   `>  Awair+ tab > Awair APIs > Local API`  
   and enable the local api.
   
2) Find the local IP of your Awair Element device.  
   You can use [Advanced IP Scanner](https://www.advanced-ip-scanner.com/) to scan the IPs.
   
3) Open `http://192.168.xxx.xxx/` in a web browser (replace this IP with the one from step 2)  
   It should display something like this:  
   ![image](https://github.com/softlion/depin/assets/190756/57ce97eb-bbf1-4eb3-bc44-560dae10053b)
   
4) Tap the `/settings/config/data` link  
   It will display a text string. The device id is the 1st value `awair-element_XXXXXX`  
   ![image](https://github.com/softlion/depin/assets/190756/9afb0e05-ec0b-47ab-a5a3-b607959b8093)

You can go back to the mobile app and disable local api, or leave it enabled.
