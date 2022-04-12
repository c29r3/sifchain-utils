#!/bin/bash

WALLET_NAME="sifchain"
BIN_FILE="$HOME/go/bin/sifnoded"
TOKEN="rowan"
RPC="http://localhost:46657"
TX_FEE="12000000000000000"
CHAIN_ID=$(curl -s $RPC/status | jq -r .result.node_info.network)
read -sp "Password: " WALLET_PWD

SELF_ADDR=$(echo -e "$WALLET_PWD" | $BIN_FILE keys list --output json | jq -r ".[] | select(.name == \"$WALLET_NAME\").address")
OPERATOR=$(echo -e "$WALLET_PWD" | $BIN_FILE keys show $WALLET_NAME --bech val --output json | jq -r .address)


while true; do
    # withdraw reward
    echo -e "$WALLET_PWD" | $BIN_FILE tx distribution withdraw-rewards $OPERATOR --fees $TX_FEE$TOKEN --commission --chain-id $CHAIN_ID --from $WALLET_NAME --node ${RPC} -y

    sleep 10

    # check current balance
    BALANCE=$($BIN_FILE q bank balances $SELF_ADDR -o json --node ${RPC} | jq -r '.balances[] | select(.denom == "rowan").amount')
    echo CURRENT BALANCE IS: $BALANCE

    RESTAKE_AMOUNT=$(echo "$BALANCE - 1000000000000000000" | bc)

    if (( $(bc <<< "$RESTAKE_AMOUNT >=  3000000000000000000") ));then
        echo "Let's delegate $RESTAKE_AMOUNT of REWARD tokens to $SELF_ADDR"
        # delegate balance
        echo -e "$WALLET_PWD" | $BIN_FILE tx staking delegate $OPERATOR "$RESTAKE_AMOUNT"$TOKEN --fees $TX_FEE$TOKEN --chain-id $CHAIN_ID --from $WALLET_NAME --node ${RPC} -y

    else
        echo "Reward is $RESTAKE_AMOUNT"
    fi
    echo "DONE"
    sleep 10800
done
