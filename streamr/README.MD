# Streamr - Becoming an [Operator](https://streamr.network/hub/network/operators)

Connecting Web3 with real time data.  
Streamr distributes publisher's live data to customers, without any server or cloud API.  
Publishers pay for publishing data. Node operators gets a cut of the data passing through them.

[Official Website](https://streamr.network/)  
[Official Discord](https://discord.gg/gZAm8P7hK8)  
[Official doc: become a node operator](https://docs.streamr.network/guides/become-an-operator/)  
[Official doc: How to run a streamr node](https://docs.streamr.network/guides/how-to-run-streamr-node/)

➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️  
➡️ You can also stake on [my Operator "Licorne"](https://streamr.network/hub/network/operators/0x561c011c6bbcd686d43efbc6449e8a69c801002e) if you don't want to become an operator yourself ⬅️  
➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️➡️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️⬅️  

Conditions to become operator
* You must stake [100 DATA](https://streamr.network/stake-and-earn/) on your Operator to get rewards. Buy them from Uniswap, Binance or [Quickswap](https://quickswap.exchange/#/swap?outputCurrency=0x3a9A81d576d83FF21f26f325066054540720fC34&swapIndex=0&currency0=ETH). Stake on the operator's page.
* Each running node will have its own polygon wallet. 
* You must fund each node with at least 0.1 MATIC (0.5 is better).  
* Open and [forward port](https://portforward.com/) 32200 from your router to your node.

Hardware requirements:
* A linux device (raspberry pi, helium miner, ...)
* A stable internet connection 24/24. Do not try if your internet connection is not stable as your DATA tokens will be slashed.


# News
Streamr is now released !  
Rerun the script to use it.  
It will ask you for a NODE_PRIVATE_KEY (which is the etherum private key of a dedicated wallet for this node, which must have a few MATICs) and your OPERATOR_CONTRACT_ADDRESS from the streamr dashboard.

If you did not "migrate" your beta operator contract yet, you should do so: simply create a new operator and abandon the old one.

# Script

The script starts the config wizard,  and creates a `config.json` file in `/usr/src/depin/streamr/.streamr/` or `/mnt/data/depin/streamr/.streamr/`  
Then it starts the node.

You can run this script multiple times, it will keep your previous settings.

## Installation

On nebra and sensecap:

```shell
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/streamr/streamr.sh')"
```

Other raspberry pi devices with docker installed (pisces, crankk, ...):
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

EVM account: 0xe0018e74856e68A62d142Ab1C77b0F7B0ca3a2Ea
