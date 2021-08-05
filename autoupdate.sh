#!/bin/bash
#Global Variables##
source $HOME/SimpleManager/global.var

##Child Script Variables##
declare -i DAYS
##

bash log "AutoUpdate/Restart script is now online."
bash bash discord_log "7"
while [[ "0" = "0" ]]; do     #This is my lazy way of making sure that the script is constantly looping.
TIME1=$(date +%H:%M)          #This stores the current time inside of a variable called TIME1
sleep 10;                     #This puts a delay on how fast the script can run, this stops the script from overloading your server.
  if [[ "$TIME1" = "20:00" ]]; then     #This statement says that once TIME0(current time) is equal to 8 PM then run the script.
  DAYS=$DAYS+1
  DTR=$((7-$DAYS))
  DTU=$((14-$DAYS))
  bash log "AutoUpdate/Restart check ran successfully at $TIME0" "Days until next restart '$DTR'" "Days until next update '$DTU'"
  bash discord_log "7"
  fi
  if [[ "$DAYS" = "7" ]]; then
  bash log "WARNING, '$serverip' will restart in 10 seconds... A second message should send when the server has successfully rebooted..."
  bash discord_log "7"
  sudo reboot
  fi
  if [[ "$DAYS" = "14" ]]; then
  DAYS=0
  if ! { sudo apt-get update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then #run update and check for errors
		bash log "SERVER UPDATE SUCCESSFUL"
		bash discord_log "7"
		else
		bash log "ERROR, UPDATE ON '$serverip' FAILED."
		fi
		
	  if ! { sudo apt-get upgrade 2>&1 || echo E: upgrade failed; } | grep -q '^[WE]:'; then #run upgrade and check for errors
		bash log "SERVER UPGRADE SUCCESSFUL"
		bash discord_log "7"
		else
		bash log "ERROR, UPGRADE ON '$serverip' FAILED."
		bash discord_log "7"
		fi
  fi
done