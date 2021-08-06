#!/bin/bash
#Global Variables##
source $HOME/SimpleManager/global.var

log () {
TIME0=$(date)    
sudo /bin/cat <<-EOM >>$FILE
    Activity logged on $TIME0
	Script Version="$APIVERSION" || Last SSH Connection $SSH_CONNECTION
    ####################################################################################
	${TAB}SERVER: $serverip${TAB}DETECTED ACTIVITY:
	${TAB} $2 
	${TAB} $3 
	${TAB} $4
EOM
}

logDump () {
TIME0=$(date)    
tail -n 99 <$FILE   > logfile.txt
curl \
  -F 'payload_json={"username": "Botty McBotFace", "content": "@everyone"}' \
  -F "file1=@logfile.txt" \
  $URL
  sleep 1;
  rm logfile.txt
}

$1