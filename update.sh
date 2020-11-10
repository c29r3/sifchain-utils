#!/bin/bash
OLD_PEERS="ec03640d0dcb1160f8cf73c33c63b64a55c93906@35.166.247.98:26656,04fad3abcf8d5c6d94d7815f9485830c280a8d73@35.166.247.98:28002,330c1b876d916f7518562b33d2749e3d1fcf7817@35.166.247.98:28004,16d9c23623e42723dfcf3dcbb11d98d989689a7a@35.166.247.98:28006"
NEW_PEERS="ec03640d0dcb1160f8cf73c33c63b64a55c93906@35.166.247.98:26656,04fad3abcf8d5c6d94d7815f9485830c280a8d73@35.166.247.98:28002,330c1b876d916f7518562b33d2749e3d1fcf7817@35.166.247.98:28004,16d9c23623e42723dfcf3dcbb11d98d989689a7a@35.166.247.98:28006,44746bbabd4707f36728164ec59cb04890d7f019@161.97.107.5"

systemctl stop sifchain; \
cd /root/sifchain/sifnode; \
git pull; \
git checkout tags/monkey-bars-testnet-4; \
make install; \
sifnoded unsafe-reset-all; \
wget -O /root/.sifnoded/config/genesis.json https://raw.githubusercontent.com/Sifchain/networks/feature/genesis/testnet/monkey-bars-testnet-4/genesis.json; \
sed -i "s|persistent_peers = \"$OLD_PEERS\"|persistent_peers = \"$NEW_PEERS\"|g" /root/.sifnoded/config/config.toml; \
systemctl start sifchain; \
systemctl status sifchain
