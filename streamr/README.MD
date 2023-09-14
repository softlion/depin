# Streamr

Connecting Web3 with real time data

[Website](https://streamr.network/)  
[Discord](https://discord.gg/gZAm8P7hK8)

You must keep [100 DATA](https://streamr.network/stake-and-earn/) in the Polygon wallet associated with your nodes to get rewards.  
Sent from Uniswap or Binance or [Quickswap](https://quickswap.exchange/#/swap?outputCurrency=0x3a9A81d576d83FF21f26f325066054540720fC34&swapIndex=0&currency0=ETH).

# Script

The script will first run the streamr config container to create the config json file.  
Streamr will ask you a few questions, the answers are on the [streamr website](https://docs.streamr.network/node-runners/run-a-node/)

```
#Choose "Generate" for Etherum private key. Do not import an existing one ! 
(well, you can import if you rerun the script a 2nd time on the same node).
#Plugins to enable: press enter (do not select/enable any additional plugins).
#Set staking key: yes (enter your eth wallet public address)
#"Path to store the configuration": Press 'enter' (keep the default path).


? Do you want to generate a new Ethereum private key or import an existing one? Generate
? Please provide the private key to import [hidden]
? Select the plugins to enable
? Do you want to participate in mining and staking? Yes
? It is recommended to set a separate beneficiary address for security reasons. Would you like to set one? Yes
? Please provide a beneficiary address (public key) 0x112233445566778899aabbccddeeff
? Select a path to store the generated config in /root/.streamr/config/default.json
: Welcome to the Streamr Network
: Your node's generated name is Ancient Harvest Direct.
: View your node in the Network Explorer:
: https://streamr.network/network-explorer/nodes/0x112233445566778899aabbccddeeff
: You can start the broker now with
: streamr-broker /root/.streamr/config/default.json
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
