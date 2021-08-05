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
	 source $HOME/SimpleManager/global.var
      fi





func_requiredRepos () { 
if [ $(dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  log "Missing python3" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get update
fi
if [ $(dpkg-query -W -f='${Status}' screen 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  log "Missing screen" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get update   
fi
clear
}



