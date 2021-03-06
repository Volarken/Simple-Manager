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
 read -p 'Press enter to continue'
##attempt fix##
 clear
 sudo bash "$0" || exit #If EUID does not equal user 0 (root) then re-run as sudo (this creates a loop until script has been ran with proper sudo) 
 exit -1
 else
 firstTimeCheck
fi
}

##function 2##
enableRCLOCAL() {
##non RC-Local related logging configurations
##SSHD Logging
if grep -qF "LogLevel INFO" /etc/ssh/sshd_config ; then	#if SSHD is not configured to log, enable it.
sed -i "s/#LogLevel INFO/LogLevel VERBOSE/" /etc/ssh/sshd_config
systemctl restart rsyslog
fi
##OVPN Logging
##
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
	 requiredReposCheck
}
##	

##function 3##
firstTimeCheck () {		#This function is used to check if the directory /etc/SimpleManager/ exists, if it does not it will assume first time setup
if test -d /etc/SimpleManager/ #If the folder exists, check to make sure all files exist, if one does not, download it.
     then
	 if test ! -f /etc/SimpleManager/global.var ; then	#Does global.var exist?
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var > /dev/null #if no, download it.
	fi
	if test ! -f /etc/SimpleManager/autoupdate.sh ; then #Does autoupdate.sh exist?
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh > /dev/null #if no, download it.
	fi
	if test ! -f /etc/SimpleManager/sshlogger.sh ; then 
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/sshlogger.sh -O $DIR/sshlogger.sh > /dev/null
	fi
	if test ! -f /etc/SimpleManager/vpnlogger.sh ; then 
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/vpnlogger.sh -O $DIR/vpnlogger.sh > /dev/null
	fi
	if test ! -f /etc/SimpleManager/send.py ; then	
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py > /dev/null
	fi
	if test ! -f /etc/SimpleManager/log ; then
	sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log > /dev/null
	fi
	 source /etc/SimpleManager/global.var #Source all variables from global.var
	 cd $DIR	 # CD into /etc/SimpleManager/ for easier accessibility.
	 updateCheck
    ##
    else
     sudo mkdir /etc/SimpleManager/	#If folder doesn't exist, create it and download all scripts.
     echo Folder Created	
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/sshlogger.sh -O $DIR/sshlogger.sh > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/vpnlogger.sh -O $DIR/vpnlogger.sh > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py > /dev/null
	 source /etc/SimpleManager/global.var	#Source all variables from global.var
	 cd $DIR	#CD into /etc/SimpleManager/ for easier accessibility 
	 updateCheck
      fi
}
#Checks Github for new version of script#
##function 4##
updateCheck(){
if [ "$APIVERSION" = "$WEBVERSION" ]; then	# If local APIVERSION does not match WEBVERSION, re-install all scripts.
TIME0=$(date)
bash log "Script up to date, last update check ran on $TIME0" #If local version does match webversion, log and move to next function.

else
	 bash log "Script outdated, current version is $APIVERSION, updating to $WEBVERSION now."
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/SimpleManager.sh -o "$0" > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/sshlogger.sh -O $DIR/sshlogger.sh > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var > /dev/null
	 sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py > /dev/null
clear
source global.var
enableRCLOCAL
fi
}
#Installs required repos#
##function 5##
requiredReposCheck () { 
if [ $(dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 0 ]; #checks if python3 is installed.
then #To speed things up and patch possible errors, each repo check will attempt to download all of the required repos.
  TIME0=$(date)
  bash log "Missing python3" "One or more required repositories are not installed, will acquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install python3-pip #right now, pip will only install if python3 is not installed.
  python3 -m pip install requests
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update
fi
if [ $(dpkg-query -W -f='${Status}' screen 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  TIME0=$(date)
  bash log "Missing screen" "One or more required repositories are not installed, will acquire now at $TIME0"
  echo You are missing required files, we will acquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  sudo apt-get install python3
  sudo apt-get install screen
  sudo apt-get install fail2ban
  sudo apt-get update   
fi
if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  TIME0=$(date)
  bash log "Missing screen" "One or more required repositories are not installed, will acquire now at $TIME0"
  echo You are missing required files, we will acquire them now. This may take a while. 
  read -p 'Press enter to continue.'
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
enableRCLOCAL
requiredReposCheck
firstTimeCheck



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
	  sudo rm -Rf webhook.var #.txt is used to interact with the logDump bash function.
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
  echo "$WEBHOOK" >> webhook.var
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
	bash log "$LogInput" || exit
	echo $LogInput
    sed -i "$(wc -l < /etc/rc.local)i\\screen -S $filename -d -m sudo bash /etc/SimpleManager/$filename \\" /etc/rc.local
	LogInput="Restarting & Enabling RC-Local... "
	bash log "$LogInput" || exit
	echo $LogInput
	systemctl restart rc-local
	systemctl enable rc-local
	echo "Script $filename should now be online. Check discord for notification."
  echo "Use number to select a file or 'stop' to return to main menu: "
else #If the selected file is referenced in rc.local, simply restart & enable rc-local
	LogInput="Restarting & Enabling RC-Local... "
	bash log "$LogInput" || exit
	echo $LogInput
    systemctl restart rc-local
	systemctl enable rc-local
	echo "Script $filename should now be online. Check discord for notification."
fi	#If the file is not in rc.local after attempting to add it, issue an error to discord.
	if ! grep -qwF "$filename" /etc/rc.local ; then
	LogInput="ERROR: Script has not been added to startup."
	echo $LogInput
	bash log "$LogInput" || exit
	TIME0=$(date)
	python3 send.py "$whRED" "$LogInput" "$TIME0"
	fi
done
#when the loop closes, send a discord notification to tell the user that setup has been completed.
LogInput="Warning: All scripts should now be online..."
sudo bash log "$LogInput" || exit
sleep 1;
TIME0=$(date)
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
	  sleep 5;
	sudo bash log "$LogInput" || exit
	sleep 1;
	TIME0=$(date)
	python3 send.py "$whBLUE" "$LogInput" "$TIME0"
    systemctl restart rc-local
     else
	 echo "Returning to main menu..."
	 mainMenu
	 fi
sleep 10;
#when finished, send a discord notification to tell the user that restart has completed.
LogInput="Warning: All scripts should now be online..."
sudo bash log "$LogInput" || exit
sleep 2;
TIME0=$(date)
python3 send.py "$whBLUE" "$LogInput" "$TIME0"
}

##main menu function 5##
logDump () { #Dump 99 newest lines of LOG to discord. 
TIME0=$(date)    
WEBHOOK_URL=$(cat /etc/SimpleManager/webhook.var)
tail -n 99 <$FILE   > logfile.txt
curl \
  -F 'payload_json={"username": "Botty McBotFace", "content": "@everyone"}' \
  -F "file1=@logfile.txt" \
  $WEBHOOK_URL
  sleep 1;
  rm logfile.txt
if test -f /etc/SimpleManager/connection-history.log ; then
curl \
  -F 'payload_json={"username": "Botty McBotFace", "content": "@everyone"}' \
  -F "file1=@connection-history.log" \
  $WEBHOOK_URL
  sleep 1;
  rm connection-history.log
 fi
  mainMenu
}
##Main Menu Function 6##
removeScripts () {
echo -e "These are the current scripts specified to run at startup.... \n"
grep -wF "screen" /etc/rc.local
echo -e "\n"
echo -e "Would you like to remove a script?"
echo "Y\N"
read -p '>>' -e quickChoice
      while [[ "$quickChoice" = "y" || "$quickChoice" = "Y" ]] ; do
	  echo "Type the script name to remove or 'stop' to return to main menu: "
	  echo "What is the name of the script you would like to remove?"
	  read -p '>>' -e REM
	  SHCHECK=$(printf "$REM" | tail -c 2)
	  
	  if [[ "$REM" = "stop" ]]; then
	  mainMenu
	  fi
	  if [[ "$REM" = "" ]]; then
	  echo "Choice is not valid, try again."
	  
	  else
	  
	  if ! grep -qwF "$REM" /etc/rc.local ; then
	  echo "Specified name does not appear in RC.LOCAL. Try again."
	  
	  else
	  
	  if [[ ! "$SHCHECK" = "sh" ]]; then
	  echo "To remove a script you must include the full name plus extension (example autoupdate.sh)"
	  echo "Please try again..."
	  
	  else
	  
	  if grep -qwF "$REM" /etc/rc.local ; then
	  
	  if grep -qwF "$REM" /etc/rc.local ; then
	  echo "Are you sure you would like to remove $REM ?"
	  read -p '>>' -e YN
	  
	  if [[ "$YN" = "Y" || "$YN" = "y" ]]; then
	  grep -v "$REM" /etc/rc.local > tmpfile
	  echo "New startup configuration..."
	  grep -wF "screen" tmpfile
	  echo "Would you like to save these changes?"
	  read -p '>>' -e YN
	  
	  if [[ "$YN" = "Y" || "$YN" = "y" ]]; then 
	  LogInput="WARNING: $REM has been removed from active scripts!"
	  sudo bash log "$LogInput" || exit
	  sleep 2;
	  python3 send.py "$whRED" "$LogInput" "$TIME0"
	  mv tmpfile /etc/rc.local
	  sudo chmod +x /etc/rc.local
	  else
	  
	  echo "Discarding changes..."
	  fi
	  fi
	  fi
	  fi
	  fi
	  fi
	  fi
	  done
	  
	  
	





}
##

mainMenu () {
##MAIN MENU##
#my script hates me and continues to download a copy of SimpleManager to /etc/SimpleManager, this makes sure its deleted. 
if test -f /etc/SimpleManager/SimpleManager.sh ; then
rm -Rf /etc/SimpleManager/SimpleManager.sh
rm -Rf /etc/SimpleManager/*.sh.1
fi
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
removeScripts
mainMenu
fi
if [[ "$MenuProcessor" = "5" ]]; then
setWebhook
mainMenu
fi
if [[ "$MenuProcessor" = "6" ]]; then
exit -1
fi
}
mainMenu

