#!/bin/bash

WALLET_NAME=sifchain
CHAIN_ID="sifchain"
OPERATOR="sifvaloper1lj3rsayj4xtrhp2e3elv4nf7lazxty27rqgngn"
CLI="/root/go/bin/sifnodecli"
RPC="http://localhost:26657"
COIN="rowan"
# telegram bot token
TG_TOKEN=""
# user telegram ID
CHAT_ID=""
PASSWD=""
SUBJECT="SIFCHAIN"

SELF_ADDR=$(echo -e "$PASSWD\n" | $CLI keys list --output json --trust-node | jq -r .[0].address)

while true; 
do 
    STATUS=$($CLI query staking validator $OPERATOR --chain-id=$CHAIN_ID --node $RPC -o json | jq -r .jailed)
    echo "Status $STATUS"
    if [[ "$STATUS" == "true" ]]; then
        echo "UNJAIL"
        if [[ $TG_TOKEN != "" ]]
        then
            MSG="Validator jailed = $STATUS"
            $(which curl) -s -H 'Content-Type: application/json' --request 'POST' -d "{\"chat_id\":\"${CHAT_ID}\",\"text\":\"${SUBJECT}\n${MSG}\"}" "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
        fi
        echo -e "$PASSWD\n$PASSWD\n" | $CLI tx slashing unjail --from $WALLET_NAME --node $RPC --gas-adjustment="1.5" --gas="200000" --fees 200000$COIN --chain-id=$CHAIN_ID -y
    fi
    sleep 300
done
