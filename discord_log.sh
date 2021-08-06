#!/bin/bash
#Global Variables##
source $HOME/SimpleManager/global.var

logDump () {
TIME0=$(date)    
tail -n 99 <$FILE   > logfile.txt
curl \
  -F 'payload_json={"username": "Botty McBotFace", "content": "@everyone"}' \
  -F "file1=@logfile.txt" \
  $WEBHOOK_URL
  sleep 1;
  rm logfile.txt
}

hookSend() {
TIME0=$(date)
WEBHOOK_URL="https://discord.com/api/webhooks/873223854556852235/ZWQDDfZOFGdTCvmPM7saO9gcarg_58pFLJBF3953vizklpKjkOs6rvABHJwgnPmwHOns"
curl \
  -H "Content-Type: application/json" \
  -d '{"username": "Botty McBotFace", "content": "@everyone", "embeds": [{"title": "$2", "color": "$3",}]}' \
  $WEBHOOK_URL

}

$1