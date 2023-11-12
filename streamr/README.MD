# Streamr

🚨🚨 It looks like your IP will be banned from some website if you host a streamr node 🚨🚨 

Connecting Web3 with real time data

[Website](https://streamr.network/)  
[Discord](https://discord.gg/gZAm8P7hK8)

You must keep [100 DATA](https://streamr.network/stake-and-earn/) in the Polygon wallet associated with your nodes to get rewards.  
Sent from Uniswap or Binance or [Quickswap](https://quickswap.exchange/#/swap?outputCurrency=0x3a9A81d576d83FF21f26f325066054540720fC34&swapIndex=0&currency0=ETH).

# News
[Migrate from brubeck to testnet](https://docs.streamr.network/guides/become-an-operator/)
* you have to rerun this script to update the docker container, auto update has been disabled by Streamr for now.

# Script

The script 1st run the config wizard.  
Streamr will ask you a few questions, the answers are on the [streamr website](https://docs.streamr.network/node-runners/run-a-node/) and also below.  
That creates a `config.json` file in `/usr/src/depin/streamr/1/.streamr/` or `/mnt/data/depin/streamr/1/.streamr/`

```
? Do you want to generate a new Ethereum private key or import an existing one? Generate
? Select the plugins to enable (none, press enter)
? Do you want to participate in mining and staking? Yes
? It is recommended to set a separate beneficiary address for security reasons. Would you like to set one? Yes
? Please provide a beneficiary address (your etherum public address) 0x112233445566778899aabbccddeeff
? Select a path to store the generated config in (press enter to accept the default one)
: Welcome to the Streamr Network
: ...
```

The script then starts the node.  
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
