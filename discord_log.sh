#!/bin/bash
#Global Variables##
source $HOME/SimpleManager/global.var

discord_log () {
TIME0=$(date)    
WEBHOOK_URL="https://discord.com/api/webhooks/872891986129063956/-2EHHb2RzPlDeoFHNq_d3TmzgL0g4_qxZct-kgcxjUoapsZqTohvlZUgMs1txGyynEVC"
tail -n $1 <$FILE   > logfile.txt
curl \
  -F 'payload_json={"username": "Botty McBotFace", "content": "@everyone"}' \
  -F "file1=@logfile.txt" \
  $WEBHOOK_URL
  sleep 1;
  rm logfile.txt
}