# Presearch

[Website](https://presearch.com/signup?rid=4757851)  
[Community on Telegram](https://t.me/PresearchNodes)  
[Discord](https://discord.com/invite/KUpshRZz2n) (less active than telegram)

You must stake 1000 pre to get the rewards. [See doc](https://account.presearch.com/tokens/usage-rewards).  
Buy PRE on Etherum: [uniswap.org](uniswap.org) Requires 20 block confirmation.  
[All exchanges](https://presearch.io/exchanges)

## Getting Started

Create [an account](https://presearch.com/signup?rid=4757851) and login

Then get your [node registration code](https://nodes.presearch.com/dashboard)

Run this script to install the docker container, auto updated by watchtower.

Windows:
```shell
pwsh -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/softlion/depin/main/presearch/presearch.ps1' | iex"
```

Or ssh into your device and run:
```shell
bash -c "$(curl 'https://raw.githubusercontent.com/softlion/depin/main/presearch/presearch.sh')"
```

## Validation

```shell
#Pisces, docker:
sudo docker logs -f presearch

#Sensecap, Nebra:
balena logs -f presearch
```

## Infos

Don't forget to claim your rewards on a regular basis.

[Project Review](https://wholovesburrito.com/product-review/presearch-node/#post-2120)

# Tip

* Star the project (tap on the start on top right)

* Donate if that script helped you !  

Multi chain account (BSC, Etherum, Arbitrum, Doge, Polygon, Avalanche, ...):

0xe0018e74856e68A62d142Ab1C77b0F7B0ca3a2Ea

![image](https://github.com/softlion/defli/assets/190756/9d4f1589-5f7f-46f4-ae0d-1190d2e22762)
