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
curl \
  -H "Content-Type: application/json" \
  -d '{"username": "Botty McBotFace", "content": "'$2'"}' \
  $WEBHOOK_URL

}

$1