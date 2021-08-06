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
##Function Handbook##
#$1 - Color#
#$2 - Message
#$3 - Time/Date
TIME0=$(date)
python3 send.py "$2" "$3" "$4"
}

$1