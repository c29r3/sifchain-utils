#!/bin/bash

GREEN="\e[92m"
NORMAL="\e[39m"

DEV_RPC="http://35.166.247.98:26657"
RPC=$(awk -F'[ ="]+' '$1 == "laddr" { print $2 }' $HOME/.sifnoded/config/config.toml | head -n 1 | sed s'|tcp|http|g')
SYNC_STATUS=$(curl -s $RPC/status | jq -r .result.sync_info.catching_up)

while [[ "$SYNC_STATUS" != "false" ]]; do
  SYNC_STATUS=$(curl -s $RPC/status | jq -r .result.sync_info.catching_up)
  CURRENT_BLOCK=$(curl -s $RPC/status | jq -r .result.sync_info.latest_block_height)
  DEV_CURRENT_BLOCK=$(curl -s $DEV_RPC/status | jq -r .result.sync_info.latest_block_height)
  echo -e $GREEN"Sync progress: $CURRENT_BLOCK\\$DEV_CURRENT_BLOCK"
  sleep 2
done

echo -e $GREEN"Node synced"
