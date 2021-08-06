#!/bin/bash
##Admin Check##
##function 1##
adminCheck () {
if [[ "$EUID" -ne 0 ]]; then
 echo -e "This script interacts with folders that only the administrator has access  to.\n please run as root/with the sudo command."
 echo
 echo -e "We will attempt to do this for you."
 echo
 read -p 'Press enter to continue'
##attempt fix##
 clear
 adminCheck
 else
 firstTimeCheck
fi
}
#Detect if Folder exits, if not, assume first time run, create folder and download scripts.#
##function 2##
firstTimeCheck () {
if test -d $HOME/SimpleManager/
     then
	 source $HOME/SimpleManager/global.var
	 updateCheck
     echo
    ##
    else
     sudo mkdir $HOME/SimpleManager/
     echo Folder Created
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -P $DIR/autoupdate.sh
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log.sh -P $DIR/log.sh
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/discord_log.sh -P $DIR/discord_log.sh
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -P $DIR/global.var
	 source $HOME/SimpleManager/global.var
	 updateCheck
      fi
}
#Checks Github for new version of script#
##function 3##
updateCheck(){
if [ "$APIVERSION" = "$WEBVERSION" ]; then
bash log.sh "Script up to date, last update check ran on $TIME0"
requiredReposCheck
else
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/SimpleManager.sh -P $0
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -P $DIR/autoupdate.sh
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log.sh -P $DIR/log.sh
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/discord_log.sh -P $DIR/discord_log.sh
	 sudo sudo wget -O https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -P $DIR/global.var
clear
sudo bash "$0"
fi
}
#Installs required repos#
##function 4##
requiredReposCheck () { 
if [ $(dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing python3" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update
fi
if [ $(dpkg-query -W -f='${Status}' screen 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing screen" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update   
fi
if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing screen" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update   
fi
clear
}
adminCheck





