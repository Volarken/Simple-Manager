#!/bin/bash
##Admin Check##
##function 1##
DIR="$HOME/SimpleManager"
adminCheck () {
if [[ "$EUID" -ne 0 ]]; then
 echo -e "This script interacts with folders that only the administrator has access  to.\n please run as root/with the sudo command."
 echo
 echo -e "We will attempt to do this for you."
 echo
 read -O 'Press enter to continue'
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
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log.sh -O $DIR/log.sh
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/discord_log.sh -O $DIR/discord_log.sh
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var
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
	 bash log.sh "Script outdated, current version is $APIVERSION, updating to $WEBVERSION now."
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/SimpleManager.sh -O $0
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log.sh -O $DIR/log.sh
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/discord_log.sh -O $DIR/discord_log.sh
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var
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
  read -O 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update
fi
if [ $(dpkg-query -W -f='${Status}' screen 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing screen" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -O 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update   
fi
if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing screen" "One or more required repositories are not installed, will aquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -O 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update   
fi
  
clear
}

##Start running functions##
adminCheck
##

##main menu function 1##
setWebhook () {
 if [[ -f $DIR/webhook.py ]]; then
    echo "Looks like you already have a webhook setup, would you like to remove it?"
    echo "Y/N"
    read -p '' -e quickChoice
      if [[ "$quickChoice" = "Y" || "$quickChoice" = "y" ]]; then
      sudo rm -Rf $DIR/webhook.py
      fi
        if [[ "$quickChoice" = "N" || "n" ]]; then 
        echo "Currently we do not allow multiple webhooks, we do plan to add this support soon." 
        echo "Press enter to return to main menu"
        read -p ''
        requiredReposCheck
        fi
        else
  echo "To setup discord notifcaitons, create a webhook on your discord server."
  echo "Please paste the Webhook URL below and press enter..."
  read -p '' WEBHOOK
  sudo /bin/cat <<-EOM >>$DIR/webhook.py
  url = '$WEBHOOK'
EOM
  echo 'Webhook set!'
  echo "Press enter to return to main menu..."
  read -p ''
  fi
}

mainMenu () {
##MAIN MENU##
clear
echo "$(tput setaf 2)"
echo -e "##############################################################
#Welcome to the Simple Management System#
##############################################################
\n
1)Dump Log File\n\
2)Check Running Scripts\n\
3)Start a Bot \n\
4)Setup Discord Notifications(Webhooks)
5)Exit
"
read -p '>>' -e MenuProcessor
echo "$(tput sgr0)"

if [[ "$MenuProcessor" = "1" ]]; then
##Dump 99 lines of log##
bash discord_log.sh "logDump"
mainMenu
fi
if [[ "$MenuProcessor" = "4" ]]; then
setWebhook
fi
}
mainMenu

