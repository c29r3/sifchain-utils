# MAINNET
PROJECT_NAME="sifchain"
BINARY_ZIP_LINK="https://github.com/Sifchain/sifnode/releases/download/mainnet-20210217130000/sifnoded-mainnet-20210217130000-linux-amd64.zip"
MONIKER="c29r3 | StakeTab"
CHAIN_ID="sifchain"
BIN_PATH="$HOME/go/bin"
CLI="sifnodecli"
NODED="sifnoded"
PERSISTENT_PEERS="8c240f71f9e060277ce18dc09d82d3bbb05d1972@13.211.43.177:26656,0120f0a48e7e81cc98829ef4f5b39480f11ecd5a@52.76.185.17:26656,bcc2d07a14a8a0b3aa202e9ac106dec0bef91fda@13.55.247.60:26656"

echo "-> INSTALL REQUIREMENTS"
apt update \
  && apt install -y zip git unzip make gcc build-essential jq


systemctl stop $PROJECT_NAME
rm -rf $HOME/.$NODED $HOME/.$CLI
  
echo "---> COMPILE BINARY FILES"
wget $BINARY_ZIP_LINK
unzip sifnoded*zip
mv sifnode* ~/go/bin
rm sifnode*zip

echo "----> INIT CONFIG FILE"
$BIN_PATH/$NODED init $MONIKER --chain-id $CHAIN_ID

echo "-----> DOWNLOAD GENESIS FILE"
curl http://44.235.108.41:26657/genesis | jq '.result.genesis' > ~/.sifnoded/config/genesis.json


sed -i 's|prof_laddr = "localhost:6060"|prof_laddr = "localhost:6091"|g' $HOME/.$NODED/config/config.toml

sed -i 's|laddr = "tcp://0.0.0.0:26656"|laddr = "tcp://0.0.0.0:27656"|g' $HOME/.$NODED/config/config.toml

sed -i 's|proxy_app = "tcp://127.0.0.1:26658"|proxy_app = "tcp://127.0.0.1:27658"|g' $HOME/.$NODED/config/config.toml

sed -i 's|laddr = "tcp://127.0.0.1:26657"|laddr = "tcp://127.0.0.1:27657"|g' $HOME/.$NODED/config/config.toml

sed -i "s|persistent_peers = \"\"|persistent_peers = \"$PERSISTENT_PEERS\"|g" $HOME/.$NODED/config/config.toml

$BIN_PATH/$CLI config trust-node true
$BIN_PATH/$CLI config chain-id $CHAIN_ID

#echo "Generating new key"
#echo "yes\n" | $BIN_PATH/$CLI keys add $PROJECT_NAME --keyring-backend test -o json &> $HOME/$PROJECT_NAME/$PROJECT_NAME\_$MONIKER\_key.json
#cat $HOME/$PROJECT_NAME/$PROJECT_NAME_key.json | jq -r .

echo "------> Creating systemd unit $PROJECT_NAME.service"
tee /etc/systemd/system/$PROJECT_NAME.service > /dev/null <<EOF  
[Unit]
Description=$PROJECT_NAME Full Node
After=network-online.target
[Service]
User=root
ExecStart=/root/go/bin/$NODED start
Restart=always
RestartSec=3
LimitNOFILE=150000
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $PROJECT_NAME
systemctl start $PROJECT_NAME
