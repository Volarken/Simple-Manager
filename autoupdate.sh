#!/bin/sudo bash
#Global Variables##
source $HOME/SimpleManager/global.var

##Child Script Variables##
declare -i DAYS
##
LogInput="AutoUpdate/Restart script is now online."
sudo bash log "$LogInput"
sudo bash sudo bash discord_log "hookSend" "$LogInput" "whGREEN"
while [[ "0" = "0" ]]; do     #This is my lazy way of making sure that the script is constantly looping.
TIME1=$(date +%H:%M)          #This stores the current time inside of a variable called TIME1
sleep 10;                     #This puts a delay on how fast the script can run, this stops the script from overloading your server.
  if [[ "$TIME1" = "20:00" ]]; then     #This statement says that once TIME0(current time) is equal to 8 PM then run the script.
  DAYS=$DAYS+1
  DTR=$((7-$DAYS))
  DTU=$((14-$DAYS))
  sudo bash log "AutoUpdate/Restart check ran successfully at $TIME0" "Days until next restart '$DTR'" "Days until next update '$DTU'"
  sudo bash discord_log "7"
  fi
  if [[ "$DAYS" = "7" ]]; then
  LogInput="WARNING, '$serverip' will restart in 10 seconds... A second message should send when the server has successfully rebooted..."
  sudo bash log "$LogInput"
  sudo bash sudo bash discord_log "hookSend" "$LogInput" "whRED"
  sudo reboot
  fi
  if [[ "$DAYS" = "14" ]]; then
  DAYS=0
  if ! { sudo apt-get update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then #run update and check for errors
		LogInput="SERVER UPDATE SUCCESSFUL. $TIME0"
		  sudo bash log "$LogInput"
		  sudo bash sudo bash discord_log "hookSend" "$LogInput" "whGREEN"
		else
		LogInput="ERROR, UPDATE ON '$serverip' FAILED."
		 sudo bash log "$LogInput"
		 sudo bash sudo bash discord_log "hookSend" "$LogInput" "whRED"
		fi
		
	  if ! { sudo apt-get upgrade 2>&1 || echo E: upgrade failed; } | grep -q '^[WE]:'; then #run upgrade and check for errors
		LogInput="SERVER UPGRADE SUCCESSFUL"
		sudo bash log "$LogInput"
		sudo bash sudo bash discord_log "hookSend" "$LogInput" "whGREEN"
		else
		LogInput="ERROR, UPGRADE ON '$serverip' FAILED. $TIME0"
		sudo bash log "$LogInput"
		sudo bash sudo bash discord_log "hookSend" "$LogInput" "whRED"
		fi
  fi
done