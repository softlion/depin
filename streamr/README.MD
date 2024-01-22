# Streamr - Becoming an [Operator](https://streamr.network/hub/network/operators)

Connecting Web3 with real time data  

[Website](https://streamr.network/)  
[Discord](https://discord.gg/gZAm8P7hK8)  
[Become a node operator](https://docs.streamr.network/guides/become-an-operator/)

➡️ You can also stake on [my Operator](https://streamr.network/hub/network/operators/0xb081961f8b4d5da919c52500f210f49edfe0c2af) if you don't want to become an operator yourself ⬅️

You must delegate [100 DATA](https://streamr.network/stake-and-earn/) to your Operator to get rewards. Buy them from Uniswap, Binance or [Quickswap](https://quickswap.exchange/#/swap?outputCurrency=0x3a9A81d576d83FF21f26f325066054540720fC34&swapIndex=0&currency0=ETH).

Each running node will have its own polygon wallet. You must fund each node with at least 0.1 MATIC (0.5 is better).  
Open and forward port 32200 from your router to your node.

# News
TestNet 3 now live !  
Rerun the script to use it.  
It will ask you for a NODE_PRIVATE_KEY (which is the etherum private key of a dedicated wallet for this node, which must have a few MATICs) and your OPERATOR_CONTRACT_ADDRESS from the streamr dashboard.

# Script

The script 1st run the config wizard and create a `config.json` file in `/usr/src/depin/streamr/.streamr/` or `/mnt/data/depin/streamr/.streamr/`

The script then starts the node.  
You can run it multiple times.

This [alternate script](https://github.com/logicethos/streamrRUN/) can install a streamr node too.

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
