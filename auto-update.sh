#!/bin/bash

SERVICE_NAME="sifchain.service"
BIN_NAME="sifnoded"
BIN_PATH="$HOME/go/bin/"


check_for_update(){
  CHECK_UPD=$(journalctl -u sifchain.service --since "15 seconds ago" | egrep  "UPGRADE" | head -n 1 | egrep -o "https://.*\.zip")
  echo $CHECK_UPD
}


while true;
do
  echo "Checking logs"
  RES=$(check_for_update)
  if [[ $RES == *"https://"* ]]
  then
    echo -e "UPDATE LINK: $RES"
    
    cd /tmp
    wget ${RES}
    unzip *zip
    chmod u+x $BIN_NAME
    SHASUM_OLD=$(shasum ${BIN_PATH}${BIN_NAME} | cut -d " " -f1)
    SHASUM_NEW=$(shasum ${BIN_NAME} | cut -d " " -f1)
    
    if [[ $SHASUM_OLD != $SHASUM_NEW ]]
    then
      echo "Replacing bin file"
      rm -f ${BIN_PATH}${BIN_NAME}
      mv ${BIN_NAME} ${BIN_PATH}
      echo "Restarting service"
      systemctl restart ${SERVICE_NAME}
    else
      echo "Binary files are same"
      rm -f ${BIN_NAME}
    fi
    rm -f rm /tmp/${BIN_NAME}*zip*
  fi
  sleep 10
done
