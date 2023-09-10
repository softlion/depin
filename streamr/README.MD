# Streamr

Connecting Web3 with real time data

[Website](https://streamr.network/)
[Discord](https://discord.gg/gZAm8P7hK8)

# Script

The script will first run the streamr config container to create the config json file.  
Streamr will ask you a few questions, the answers are on the [streamr website](https://docs.streamr.network/node-runners/run-a-node/)

```
#Choose "Generate" for Etherum private key. Do not import an existing one !
#Plugins to enable: press enter (do not select/enable any additional plugins).
#Set staking key: yes (enter your eth wallet public address)
#"Path to store the configuration": Press 'enter' (keep the default path).
```

Then it will start the node container with this config file.

You can run it multiple times.
