#!/bin/bash
##Admin Check##
##function 1##
DIR="/etc/SimpleManager"
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
##function 2##
firstTimeCheck () {
if test -d /etc/SimpleManager/	
     then
	 source /etc/SimpleManager/global.var
	 cd $DIR
	 updateCheck
     echo
    ##
    else
	 if test ! -f /etc/systemd/system/rc-local.service ; then
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
if test ! -f /etc/rc.local ; then
	 bash log "/etc/rc.local not detected, will generate now."
	printf '%s\n' '#!/bin/bash' 'exit 0' | sudo tee -a /etc/rc.local
	sudo chmod +x /etc/rc.local
	 fi
     sudo mkdir /etc/SimpleManager/
     echo Folder Created
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/global.var -O $DIR/global.var
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/send.py -O $DIR/send.py
	 source /etc/SimpleManager/global.var
	 cd $DIR
	 updateCheck
      fi
}
#Checks Github for new version of script#
##function 3##
updateCheck(){
if [ "$APIVERSION" = "$WEBVERSION" ]; then
bash log "Script up to date, last update check ran on $TIME0"
requiredReposCheck
else
	 bash log "Script outdated, current version is $APIVERSION, updating to $WEBVERSION now."
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/SimpleManager.sh -O $0
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/autoupdate.sh -O $DIR/autoupdate.sh
	 sudo sudo wget https://raw.githubusercontent.com/Volarken/Simple-Manager/main/log -O $DIR/log
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
  bash log "Missing python3" "One or more required repositories are not installed, will acquire now at $TIME0"
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -O 'Press enter to continue.'
  sudo apt-get install python3
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
 if [[ -f webhook.py ]]; then
    echo "Looks like you already have a webhook setup, would you like to remove it?"
    echo "Y/N"
    read -p '' -e quickChoice
      if [[ "$quickChoice" = "Y" || "$quickChoice" = "y" ]]; then
      sudo rm -Rf webhook.py
	  sudo rm -Rf webhook.txt
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
  echo "$WEBHOOK" >> webhook.txt
  sudo /bin/cat <<-EOM >>webhook.py
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
clear
echo "WARNING : All scripts when a new script is enabled..."
echo "The following scripts were found; select one to start...:"
# set the prompt used by select, replacing "#?"
echo "Use number to select a file or 'stop' to return to main menu: "
# allow the user to choose a file
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
	if grep -qwF "$filename" /etc/rc.local ; then
	LogInput="Adding $filename to startup scripts... "
	bash log "$LogInput"
	echo $LogInput
    sed -i "`wc -l < /etc/rc.local`i\\screen -S $filename -d -m sudo bash /etc/SimpleManager/$filename -\\" /etc/rc.local
	LogInput="Restarting & Enabling RC-Local... "
	bash log "$LogInput"
	echo $LogInput
	systemctl restart rc-local
	systemctl enable rc-local
	echo "Script $filename should now be online. Check discord for notification."
else
	LogInput="Restarting & Enabling RC-Local... "
	bash log "$LogInput"
	echo $LogInput
    systemctl restart rc-local
	systemctl enable rc-local
	echo "Script $filename should now be online. Check discord for notification."
fi
	if grep -qwF "$filename" /etc/rc.local ; then
	LogInput="ERROR: Script has not been added to startup."
	echo $LogInput
	bash log "$LogInput"
	python3 send.py "$whRED" "$LogInput" "$TIME0"
	fi
done
#back to my original code.#
LogInput="Warning: All scripts should now be online..."
sudo bash log "$LogInput"
sleep 1;
python3 send.py "$whBLUE" "$LogInput" "$TIME0"
mainMenu
}

##main menu function 3##
restartScripts () {
echo "The following scripts were found; select one to stop...:"
# set the prompt used by select, replacing "#?"
echo "Use number to select a file or 'stop' to return to main menu: "
# allow the user to choose a file
select filename in /etc/init.d/*.sh
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
	if test -f /etc/init.d/$filename ; then
	sudo rm -Rf /etc/init.d/$filename
	fi
	sudo /bin/cat <<-EOM >>/etc/init.d/$filename
		#!/bin/bash
		DIR="/etc/SimpleManager"
		start="$filename"
		screen -S $start -d -m sudo bash $DIR/$start
EOM
	sudo chmod +x /etc/init.d/$filename
	LogInput="Attempting to start script $filename ... "
	bash log "$LogInput"
	echo $LogInput
	if test ! -f /etc/init.d/$filename ; then
	LogInput="ERROR: Script has not been added to startup."
	echo $LogInput
	bash log "$LogInput"
	python3 send.py "$whRED" "$LogInput" "$TIME0"
	fi
	if ! screen -list | grep -q "$filename"; then
   screen -S $filename -d -m sudo bash $filename
	else
	LogInput="ERROR while starting $filename ... Screen already running..."
	bash log "$LogInput"
	echo $LogInput
	fi
done
#back to my original code.#
LogInput="Warning: All scripts should now be online..."
sudo bash log "$LogInput"
sleep 2;
python3 send.py "$whBLUE" "$LogInput" "$TIME0"
}

logDump () {
TIME0=$(date)    
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
#Welcome to the Simple Management System#
##############################################################
\n
1)Dump Log File\n\
2)Start/Enable Scripts\n\
3)View / Restart Scripts\n\
4)Setup Discord Notifications(Webhooks)\n\
5)Exit
"
read -p '>>' -e MenuProcessor
echo "$(tput sgr0)"

if [[ "$MenuProcessor" = "1" ]]; then
##Dump 99 lines of log##
logDump
mainMenu
fi
if [[ "$MenuProcessor" = "2" ]]; then
startScripts
mainMenu
fi
if [[ "$MenuProcessor" = "3" ]]; then
restartScripts
mainMenu
fi
if [[ "$MenuProcessor" = "4" ]]; then
setWebhook
mainMenu
fi
}
mainMenu

