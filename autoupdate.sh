#!/bin/bash
#Global Variables##
source $HOME/SimpleManager/global.var

##Child Script Variables##
declare -i DAYS
##
discord_log () {
WEBHOOK_URL="https://discord.com/api/webhooks/872891986129063956/-2EHHb2RzPlDeoFHNq_d3TmzgL0g4_qxZct-kgcxjUoapsZqTohvlZUgMs1txGyynEVC"
tail -n $1 <$FILE   > logfile.txt
curl \
  -F 'payload_json={"username": "Botty McBotFace", "content": "@everyone"}' \
  -F "file1=@logfile.txt" \
  $WEBHOOK_URL
  sleep 1;
  rm logfile.txt
}

log () {
sudo /bin/cat <<-EOM >>$FILE
    Log created at $TIME0
	Script Version="$APIVERSION" || Last SSH Connection $SSH_CONNECTION
    ####################################################################################
	${TAB}SERVER: $serverip${TAB}DETECTED ACTIVITY:
	${TAB} $1 
	${TAB} $2 
	${TAB} $3
	${TAB}END
EOM
}

log "AutoUpdate/Restart script is now online."
discord_log "7"
while [[ "0" = "0" ]]; do     #This is my lazy way of making sure that the script is constantly looping.
TIME1=$(date +%H:%M)          #This stores the current time inside of a variable called TIME1
sleep 10;                     #This puts a delay on how fast the script can run, this stops the script from overloading your server.
  if [[ "$TIME1" = "20:00" ]]; then     #This statement says that once TIME0(current time) is equal to 8 PM then run the script.
  DAYS=$DAYS+1
  DTR=$((7-$DAYS))
  DTU=$((14-$DAYS))
  log "AutoUpdate/Restart check ran successfully at $TIME0" "Days until next restart '$DTR'" "Days until next update '$DTU'"
  discord_log "7"
  fi
  if [[ "$DAYS" = "7" ]]; then
  log "WARNING, '$serverip' will restart in 10 seconds... A second message should send when the server has successfully rebooted..."
  discord_log "7"
  sudo reboot
  fi
  if [[ "$DAYS" = "14" ]]; then
  DAYS=0
  if ! { sudo apt-get update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then #run update and check for errors
		log "SERVER UPDATE SUCCESSFUL"
		discord_log "7"
		else
		log "ERROR, UPDATE ON '$serverip' FAILED."
		fi
		
	  if ! { sudo apt-get upgrade 2>&1 || echo E: upgrade failed; } | grep -q '^[WE]:'; then #run upgrade and check for errors
		log "SERVER UPGRADE SUCCESSFUL"
		discord_log "7"
		else
		log "ERROR, UPGRADE ON '$serverip' FAILED."
		discord_log "7"
		fi
  fi
done