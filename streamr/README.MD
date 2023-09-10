# Streamr

Connecting Web3 with real time data

[Website](https://streamr.network/)  
[Discord](https://discord.gg/gZAm8P7hK8)

You must [stake 100 DATA](https://streamr.network/stake-and-earn/) on your Polygon wallet to get rewards.  
Sent from Uniswap or Binance or [Quickswap](https://quickswap.exchange/#/swap?outputCurrency=0x3a9A81d576d83FF21f26f325066054540720fC34&swapIndex=0&currency0=ETH).

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

## Installation

On nebra and sensecap:

```shell
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/streamr/streamr.sh')"
```

Other raspberry pi devices with docker installed:
```shell
sudo bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/streamr/streamr.sh')"
```

From Windows:
```powershell
pwsh -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/softlion/depin/main/streamr/streamr.ps1' | iex"
```

# Tip

* Star the project (tap on the start on top right)

* Donate if those scripts helped you !  

Multi chain Metamask account (BSC, Etherum, Arbitrum, Doge, Polygon, Avalanche, ...):

0xe0018e74856e68A62d142Ab1C77b0F7B0ca3a2Ea

![image](https://github.com/softlion/defli/assets/190756/9d4f1589-5f7f-46f4-ae0d-1190d2e22762)
