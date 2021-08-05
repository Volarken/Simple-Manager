#!/bin/bash
##base variables##
if test -d $HOME/SimpleManager/
     then
	 source $HOME/SimpleManager/global.var
     echo
    ##
    else
     sudo mkdir $HOME/SimpleManager/
     echo Folder Created
	 wget ##add downloads for all files here pls
	 wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh
	 wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log.sh
	 wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/discord_log.sh
	 wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var
	 
	 source $HOME/SimpleManager/global.var
      fi

func_autoUpdate(){
if [ "$APIVERSION" = "$WEBVERSION" ]; then
LogInput="Script up to date, last update check ran on "
func_logEvent
else
LogInput="Script is outdated, running update protocols on "
func_logEvent
sudo mkdir -p /usr/bin/betterssh
sudo -s curl https://raw.githubusercontent.com/Volarken/betterssh/main/version.txt -o /usr/bin/betterssh/version.txt > /dev/null
sudo -s curl -L https://raw.githubusercontent.com/Volarken/betterssh/main/betterssh.sh -o "$0" > /dev/null
clear
sudo bash "$0"
fi

func_requiredRepos () { 
if [ $(dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing python3" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get update
fi
if [ $(dpkg-query -W -f='${Status}' screen 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing screen" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get update   
fi
clear
}





