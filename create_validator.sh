desmoscli tx staking create-validator \
  --amount=40000000trwn \
  --pubkey=$(desmosd tendermint show-validator) \
  --moniker=$(cat /root/desmos/acc_name.txt) \
  --chain-id=monkey-bars \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --gas="auto" \
  --gas-adjustment="1.2" \
  --gas-prices="0.025trwn" \
  --from=sifchain
