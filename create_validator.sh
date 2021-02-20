# MAINNET
PSWD=$1
MONIKER="c29r3 | StakeTab"
WALLET_NAME="sifchain"
RPC="tcp://localhost:27657"

while true;
do
  echo -e "$PSWD\n$PSWD\n" | /root/go/bin/sifnodecli tx staking create-validator \
    --amount=1000000rowan \
    --pubkey=$(/root/go/bin/sifnoded tendermint show-validator) \
    --moniker=$MONIKER \
    --chain-id=sifchain \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="1" \
    --gas="auto" \
    --gas-adjustment="1.2" \
    --gas-prices="0.025rowan" \
    --from=$WALLET_NAME \
    --yes \
    --node $RPC
  sleep 15
done
