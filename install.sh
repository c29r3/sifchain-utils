PROJECT_NAME="sifchain"
MONIKER=$(cat $HOME/$PROJECT_NAME/acc_name.txt)
CHAIN_ID="monkey-bars"
BIN_PATH="$HOME/go/bin"
CLI="sifnodecli"
NODED="sifnoded"
PERSISTENT_PEERS="bd17ce50e4e07b5a7ffc661ed8156ac8096f57ce@35.166.247.98:26656,f8f5d01fdc73e1b536084bbe42d0a81479f882b3@35.166.247.98:28002,f27548f03a4179b7a4dc3c8a62fcfc5f84be15ff@35.166.247.98:28004,dd35505768be507af3c76f5a4ecdb272537e398f@35.166.247.98:28006"

echo "-> INSTALL REQUIREMENTS"
apt update \
  && apt install -y zip git unzip make gcc build-essential jq


echo "---> COMPILE BINARY FILES"
mkdir ~/$PROJECT_NAME; \
cd ~/$PROJECT_NAME; \
git clone https://github.com/Sifchain/sifnode.git; \
cd sifnode; \
make install; \
$BIN_PATH/$NODED version --long

echo "----> INIT CONFIG FILE"
$BIN_PATH/$NODED init $MONIKER --chain-id $CHAIN_ID

echo "-----> DOWNLOAD GENESIS FILE"
curl -s https://raw.githubusercontent.com/Sifchain/networks/feature/genesis/testnet/monkey-bars-testnet-3/genesis.json | jq . > $HOME/.$NODED/config/genesis.json


sed -i 's|prof_laddr = "localhost:6060"|prof_laddr = "localhost:6091"|g' $HOME/.$NODED/config/config.toml

sed -i 's|laddr = "tcp://0.0.0.0:26656"|laddr = "tcp://0.0.0.0:27656"|g' $HOME/.$NODED/config/config.toml

sed -i 's|proxy_app = "tcp://127.0.0.1:26658"|proxy_app = "tcp://127.0.0.1:27658"|g' $HOME/.$NODED/config/config.toml

sed -i 's|laddr = "tcp://127.0.0.1:26657"|laddr = "tcp://127.0.0.1:27657"|g' $HOME/.$NODED/config/config.toml

sed -i "s|persistent_peers = \"\"|persistent_peers = \"$PERSISTENT_PEERS\"|g" $HOME/.$NODED/config/config.toml

$BIN_PATH/$CLI config trust-node true
$BIN_PATH/$CLI config keyring-backend test
$BIN_PATH/$CLI config chain-id $CHAIN_ID

echo "Generating new key"
echo "yes\n" | $BIN_PATH/$CLI keys add $PROJECT_NAME --keyring-backend test -o json &> $HOME/$PROJECT_NAME/$PROJECT_NAME_key.json

cat $HOME/$PROJECT_NAME/$PROJECT_NAME_key.json | jq -r .

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
