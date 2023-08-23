Follow the [instructions](https://elementdata.xyz/configuration)

You will need an `Await Element` device for this project.

# Additional FAQ

## How to get the awair ID when you have multiple sensors in your cloud account

1) On the awair mobile app, tap on the device you want to get the id then go to  
   `>  Awair+ tab > Awair APIs > Local API` and enable the local api.
2) Find the local IP of your awair device, for example using [Advanced IP Scanner](https://www.advanced-ip-scanner.com/)
3) Open `http://the-local-ip-of-your-awair/` in a web browser  
   It should display something like this:  
   ![image](https://github.com/softlion/depin/assets/190756/57ce97eb-bbf1-4eb3-bc44-560dae10053b)
4) Tap the `/settings/config/data` link  
   It will display a text string. The device id is the 1st value `awair-element_XXXXXX`  
   ![image](https://github.com/softlion/depin/assets/190756/9afb0e05-ec0b-47ab-a5a3-b607959b8093)

You can go back to the mobile app and disable local api.
