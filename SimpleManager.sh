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
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py
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
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py
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

##main menu function 4##
setWebhook () {
 if [[ -f $DIR/webhook.py ]]; then
    echo "Looks like you already have a webhook setup, would you like to remove it?"
    echo "Y/N"
    read -p '' -e quickChoice
      if [[ "$quickChoice" = "Y" || "$quickChoice" = "y" ]]; then
      sudo rm -Rf $DIR/webhook.py
	  sudo rm -Rf $DIR/webhook.txt
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
  echo "$WEBHOOK" >> $DIR/webhook.txt
  sudo /bin/cat <<-EOM >>$DIR/webhook.py
url = '$WEBHOOK'
EOM
  echo 'Webhook set!'
  echo "Press enter to return to main menu..."
  read -p ''
  requiredReposCheck
  fi
}
##main menu function 2##
startScripts() {
##start scripts##
screen -S autoupdate -d -m sudo bash $DIR/autoupdate.sh
##
LogInput="Warning: All scripts should now be online..."
$log
sleep 10;
python3 send.py "$whBLUE" "$whlog"

}
##main menu function 3##
stopScripts () {
screen -ls
echo "Would you like to restart the scripts?"
case $yn in
	[Yy]* ) 
	LogInput="WARNING! ALL SERVER SCRIPTS ARE RESTARTING. EACH SCRIPT SHOULD SEND A MESSAGE WHEN SUCCESSFUL..."
	$log
	python3 send.py "$whRED" "$whlog"
	sleep 5;
	##kill screens
	screen -X -S autoupdate quit
	##
	
	startScripts
	[Nn]* ) 
  echo "Press enter to return to main menu..."
  read -p ''
  mainMenu
  ;;
   * ) echo "Please answer yes or no.";;
    esac
fi
else
mainMenu
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
2)Start Scripts\n\
3)View / Restart Scripts\n\
4)Setup Discord Notifications(Webhooks)\n\
5)Exit
"
read -p '>>' -e MenuProcessor
echo "$(tput sgr0)"

if [[ "$MenuProcessor" = "1" ]]; then
##Dump 99 lines of log##
bash log.sh "logDump"
mainMenu
fi
if [[ "$MenuProcessor" = "2" ]]; then
startScripts
mainMenu
fi
if [[ "$MenuProcessor" = "3" ]]; then
stopScripts
mainMenu
fi
if [[ "$MenuProcessor" = "4" ]]; then
setWebhook
mainMenu
fi
}
mainMenu

