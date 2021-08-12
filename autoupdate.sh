#!/bin/bash
#Global Variables##
cd /etc/SimpleManager/
source global.var



##Child Script Variables##
declare -i DAYS
##
LogInput="AutoUpdate/Restart script is now online."
sudo bash log "$LogInput"
python3 send.py "$whGREEN" "$LogInput" "$TIME0"
while [[ "0" = "0" ]]; do     #This is my lazy way of making sure that the script is constantly looping.
TIME1=$(date +%H:%M)          #This stores the current time inside of a variable called TIME1
sleep 40;                     #This puts a delay on how fast the script can run, this stops the script from overloading your server.
  if [[ "$TIME1" = "06:00" ]]; then     #This statement says that once TIME0(current time) is equal to 8 PM then run the script.
  DAYS=$(cat d.txt)
  DAYS=$DAYS+1
  echo "$DAYS" > d.txt
  if [[ "$DAYS" -ge 7 ]]; then
  DTR=$((14-$DAYS))
  else  
  DTR=$((7-$DAYS))
  fi
  DTU=$((14-$DAYS))
  LogInput="AutoUpdate/Restart check ran successfully at $TIME0 | Days until next restart $DTR | Days until next update $DTU"
  sudo bash log "$LogInput"
  python3 send.py "$whGREEN" "$LogInput" "$TIME0"
  ##check for script updates daily
  if [ "$APIVERSION" = "$WEBVERSION" ]; then	# If local APIVERSION does not match WEBVERSION, re-install all scripts.
bash log "Script up to date, last update check ran on $TIME0" #If local version does match webversion, log and move to next function.
else
	 bash log "Script outdated, current version is $APIVERSION, updating to $WEBVERSION now."
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/sshlogger.sh -O $DIR/sshlogger.sh
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py
clear
source global.var
fi
  ##
  fi
  if [[ "$DAYS" = "7" ]]; then
  LogInput="WARNING, server will restart in 10 seconds... A second message should send when the server has successfully rebooted..."
  sudo bash log "$LogInput"
  python3 send.py "$whRED" "$LogInput" "$TIME0"
  sleep 10;
  sudo reboot
  fi
  if [[ "$DAYS" = "14" ]]; then
  echo "0" > d.txt
  echo "$DAYS" > $DIR/d.txt  
  if ! { sudo apt-get update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then #run update and check for errors
		LogInput="SERVER UPDATE SUCCESSFUL."
		  sudo bash log "$LogInput"
		  python3 send.py "$whGREEN" "$LogInput" "$TIME0"
		else
		LogInput="ERROR, UPDATE ON SERVER FAILED."
		 sudo bash log "$LogInput"
		 python3 send.py "$whRED" "$LogInput" "$TIME0"
		fi
		
	  if ! { sudo apt-get upgrade 2>&1 || echo E: upgrade failed; } | grep -q '^[WE]:'; then #run upgrade and check for errors
		LogInput="SERVER UPGRADE SUCCESSFUL"
		sudo bash log "$LogInput"
		python3 send.py "$whGREEN" "$LogInput" "$TIME0"
		else
		LogInput="ERROR, UPGRADE ON SERVER FAILED. $TIME0"
		sudo bash log "$LogInput"
		python3 send.py "$whGREEN" "$LogInput" "$TIME0"
		fi
   LogInput="WARNING, SERVER will restart in 10 seconds... A second message should send when the server has successfully rebooted..."
  sudo bash log "$LogInput"
  python3 send.py "$whRED" "$LogInput" "$TIME0"
  sleep 10;
  sudo reboot
  fi
done