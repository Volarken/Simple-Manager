#!/bin/bash
##Admin Check##
##function 1##
DIR="/etc/SimpleManager" #Sets the "DIR" variable to be used later, this variable is defined in case /global.var has not yet been downloaded.
adminCheck () {	#This function checks to make sure that the script is being run as SUDO
if [[ "$EUID" -ne 0 ]]; then
 echo -e "This script interacts with folders that only the administrator has access  to.\n please run as root/with the sudo command."
 echo
 echo -e "We will attempt to do this for you."
 echo
 read -O 'Press enter to continue'
##attempt fix##
 clear
 sudo bash "$0" #If EUID does not equal user 0 (root) then re-run as sudo (this creates a loop until script has been ran with proper sudo)
 else
 firstTimeCheck #If EUID is 0, move to the next function. 
fi
}

##function 2##
enableRCLOCAL() {
if grep -qF "LogLevel INFO" /etc/ssh/sshd_config ; then	#if SSHD is not configured to log, enable it.
sed -i "s/#LogLevel INFO/LogLevel VERBOSE/" /etc/ssh/sshd_config
systemctl restart rsyslog
fi
if test ! -f /etc/systemd/system/rc-local.service ; then	#If rc-local.service does not exist, create it.
	 bash log "RC-LOCAL.SERVICE not detected, will generate now"
	 sudo /bin/cat <<-EOM >>/etc/systemd/system/rc-local.service
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
EOM
fi
if test ! -f /etc/rc.local ; then	# If rc.local does not exist, create it.
	 bash log "/etc/rc.local not detected, will generate now."
	printf '%s\n' '#!/bin/bash' 'exit 0' | sudo tee -a /etc/rc.local
	sudo chmod +x /etc/rc.local
	 fi
}
##	

##function 3##
firstTimeCheck () {		#This function is used to check if the directory /etc/SimpleManager/ exists, if it does not it will assume first time setup
if test -d /etc/SimpleManager/ #If the folder exists, check to make sure all files exist, if one does not, download it.
     then
	 if test ! -f /etc/SimpleManager/global.var ; then	#Does global.var exist?
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var #if no, download it.
	fi
	if test ! -f /etc/SimpleManager/autoupdate.sh ; then #Does autoupdate.sh exist?
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh #if no, download it.
	fi
	if test ! -f /etc/SimpleManager/sshlogger.sh ; then 
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/sshlogger.sh -O $DIR/sshlogger.sh
	fi
	if test ! -f /etc/SimpleManager/send.py ; then	
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py 
	fi
	if test ! -f /etc/SimpleManager/log ; then
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log
	fi
	 enableRCLOCAL
	 source /etc/SimpleManager/global.var #Source all variables from global.var
	 cd $DIR	 # CD into /etc/SimpleManager/ for easier accessibility.
	 updateCheck # Move to next function.
    ##
    else
	 enableRCLOCAL
     sudo mkdir /etc/SimpleManager/	#If folder doesn't exist, create it and download all scripts.
     echo Folder Created	
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/sshlogger.sh -O $DIR/sshlogger.sh
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py
	 source /etc/SimpleManager/global.var	#Source all variables from global.var
	 cd $DIR	#CD into /etc/SimpleManager/ for easier accessibility 
	 updateCheck	#Move to the next function
      fi
}
#Checks Github for new version of script#
##function 4##
updateCheck(){
if [ "$APIVERSION" = "$WEBVERSION" ]; then	# If local APIVERSION does not match WEBVERSION, re-install all scripts.
bash log "Script up to date, last update check ran on $TIME0" #If local version does match webversion, log and move to next function.
requiredReposCheck
else
	 bash log "Script outdated, current version is $APIVERSION, updating to $WEBVERSION now."
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/SimpleManager.sh -O $0
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/sshlogger.sh -O $DIR/sshlogger.sh
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py
clear
source global.var
requiredReposCheck
fi
}
#Installs required repos#
##function 5##
requiredReposCheck () { 
if [ $(dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 0 ]; #checks if python3 is installed.
then #To speed things up and patch possible errors, each repo check will attempt to download all of the required repos.
  bash log "Missing python3" "One or more required repositories are not installed, will acquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -r 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install python3-pip #right now, pip will only install if python3 is not installed.
  python3 -m pip install requests
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update
fi
if [ $(dpkg-query -W -f='${Status}' screen 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing screen" "One or more required repositories are not installed, will acquire now at $TIME0"
  echo You are missing required files, we will acquire them now. This may take a while. 
  read -O 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update   
fi
if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  bash log "Missing screen" "One or more required repositories are not installed, will acquire now at $TIME0"
  echo You are missing required files, we will acquire them now. This may take a while. 
  read -r 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update   
fi
  
clear
}
##You will notice this does not call the main menu function.
#This is because the full script has not been loaded and therefore mainMenu has not yet been defined.
#Instead, we will let the script continue to initialize the rest of defined functions.
##Start running functions 1-4##
adminCheck
##

##main menu function 1##
webhookWarning() {	#This is a warning that is issued when trying to run script functions that require a webhook.
if test ! -f webhook.py ; then
echo "WARNING: Using functions in this script before setting discord webhook could cause errors..."
echo "Would you like to set a webhook now?"
echo "Y/N"
 read -p '>>' -e quickChoice
      if [[ "$quickChoice" = "Y" || "$quickChoice" = "y" ]]; then
      setWebhook
	  fi
	 fi
}
##main menu function 2##
setWebhook () { #Allows you to set custom webhook for the running server.
 if [[ -f webhook.py ]]; then #Notify user if webhook file already exists
    echo "Looks like you already have a webhook setup, would you like to remove it?" 
    echo "Y/N"
    read -p '>>' -e quickChoice
      if [[ "$quickChoice" = "Y" || "$quickChoice" = "y" ]]; then #If Y/y , remove webhook files.
      sudo rm -Rf webhook.py #These webhook files simply store 1 variable, .py is used to interact with the python send script.
	  sudo rm -Rf webhook.txt #.txt is used to interact with the logDump bash function.
	  #this method isnt super effecient, will work to make local variable storage simplified in the future.
      fi
        if [[ "$quickChoice" = "N" || "n" ]]; then #Multiple webhook support not yet implemented. 
        echo "Currently we do not allow multiple webhooks, we do plan to add this support soon." 
        echo "Press enter to return to main menu"
        read -p ''
        requiredReposCheck
        fi
        else #If the variable file webhook.py does not exist, set webhook and generate variable files.
  echo "To setup discord notifcaitons, create a webhook on your discord server."
  echo "Please paste the Webhook URL below and press enter..."
  read -p '>>' WEBHOOK
  echo "$WEBHOOK" >> webhook.txt
  sudo /bin/cat <<-EOM >>webhook.py
url = '$WEBHOOK'
EOM
  echo 'Webhook set!'
  echo "Press enter to return to main menu..."
  read -p ''
  mainMenu
  fi
}
##main menu function 3##
startScripts() { #This function is used to add scripts to startup, if already in startup, restart rc-local.service
##start scripts##
clear
echo "WARNING : All scripts will restart when a new script is enabled..."
echo "The following scripts were found; select one to start...:"
# allow the user to choose a file
echo "Use number to select a file or 'stop' to return to main menu: "
select filename in *.sh
do
    # leave the loop if the user says 'stop'
    if [[ "$REPLY" == stop ]]; then break; fi

    # complain if no file was selected, and loop to ask again
    if [[ "$filename" == "" ]]
    then
        echo "'$REPLY' is not a valid number"
        continue
    fi
    # now we can use the selected file
	if ! grep -qwF "$filename" /etc/rc.local ; then	#If the selected file is NOT referenced in rc.local, add it to startup 
	LogInput="Adding $filename to startup scripts... "
	bash log "$LogInput"
	echo $LogInput
    sed -i "$(wc -l < /etc/rc.local)i\\screen -S $filename -d -m sudo bash /etc/SimpleManager/$filename \\" /etc/rc.local
	LogInput="Restarting & Enabling RC-Local... "
	bash log "$LogInput"
	echo $LogInput
	systemctl restart rc-local
	systemctl enable rc-local
	echo "Script $filename should now be online. Check discord for notification."
  echo "Use number to select a file or 'stop' to return to main menu: "
else #If the selected file is referenced in rc.local, simply restart & enable rc-local
	LogInput="Restarting & Enabling RC-Local... "
	bash log "$LogInput"
	echo $LogInput
    systemctl restart rc-local
	systemctl enable rc-local
	echo "Script $filename should now be online. Check discord for notification."
fi	#If the file is not in rc.local after attempting to add it, issue an error to discord.
	if ! grep -qwF "$filename" /etc/rc.local ; then
	LogInput="ERROR: Script has not been added to startup."
	echo $LogInput
	bash log "$LogInput"
	python3 send.py "$whRED" "$LogInput" "$TIME0"
	fi
done
#when the loop closes, send a discord notification to tell the user that setup has been completed.
LogInput="Warning: All scripts should now be online..."
sudo bash log "$LogInput"
sleep 1;
python3 send.py "$whBLUE" "$LogInput" "$TIME0"
mainMenu
}

##main menu function 4##
restartScripts () { #shows the running screens and allows user to restart all scripts
echo "Here are the current running scripts..."
sudo screen -ls
echo "Would you like to restart all scripts?"
echo "Y/N"
 read -p '>>' -e quickChoice
      if [[ "$quickChoice" = "Y" || "$quickChoice" = "y" ]]; then
	  LogInput="WARNING: ALL SCRIPTS ARE RESTARTING, WATCH DISCORD NOTIFCATIONS FOR VERIFICATION OF SUCCESSFUL STARTUP FOR EACH SCRIPT..."
	sudo bash log "$LogInput"
	sleep 1;
	python3 send.py "$whBLUE" "$LogInput" "$TIME0"
    systemctl restart rc-local
     else
	 echo "Returning to main menu..."
	 fi

#when finished, send a discord notification to tell the user that restart has completed.
LogInput="Warning: All scripts should now be online..."
sudo bash log "$LogInput"
sleep 2;
python3 send.py "$whBLUE" "$LogInput" "$TIME0"
}

##main menu function 5##
logDump () { #Dump 99 newest lines of LOG to discord. 
TIME0=$(date)    
WEBHOOK_URL=$(cat /etc/SimpleManager/webhook.txt)
tail -n 99 <$FILE   > logfile.txt
curl \
  -F 'payload_json={"username": "Botty McBotFace", "content": "@everyone"}' \
  -F "file1=@logfile.txt" \
  $WEBHOOK_URL
  sleep 1;
  rm logfile.txt
  mainMenu
}

mainMenu () {
##MAIN MENU##
clear
echo "$(tput setaf 2)"
echo -e "##############################################################
#######Welcome to the Simple Management System################
##############################################################
\n
1)Dump Log File\n\
2)Start/Enable Scripts\n\
3)View / Restart Scripts\n\
4)Remove Script from Startup\n\
5)Setup Discord Notifications(Webhooks)\n\
6)Exit
"
read -p '>>' -e MenuProcessor
echo "$(tput sgr0)"

if [[ "$MenuProcessor" = "1" ]]; then
##Dump 99 lines of log##
webhookWarning
logDump
mainMenu
fi
if [[ "$MenuProcessor" = "2" ]]; then
webhookWarning
startScripts
mainMenu
fi
if [[ "$MenuProcessor" = "3" ]]; then
webhookWarning
restartScripts
mainMenu
fi
if [[ "$MenuProcessor" = "4" ]]; then
echo "WARNING: Not yet programmed, im getting to it though :)"
echo "Press enter to return to mainMenu"
read -e ''
#webhookWarning
#removeScripts
mainMenu
fi
if [[ "$MenuProcessor" = "5" ]]; then
setWebhook
mainMenu
fi
if [[ "$MenuProcessor" = "6" ]]; then
exit
fi
}
mainMenu

