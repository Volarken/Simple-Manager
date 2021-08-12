#!/bin/bash
#Global Variables##
cd /etc/SimpleManager/
source global.var


#cat /var/log/syslog | grep "MULTI_sva: pool returned" > x.txt

##Child Script Variables##
##
LogInput="VPN Logger script is now online."
sudo bash log "$LogInput"
python3 send.py "$whGREEN" "$LogInput" "$TIME0"
while [[ "0" = "0" ]]; do     #This is my lazy way of making sure that the script is constantly looping.
sleep 10;                     #This puts a delay on how fast the script can run, this stops the script from overloading your server.  
  sudo cat /var/log/syslog | grep "MULTI_sva" | grep "@raymore" >> cons.txt
  sudo cat /var/log/syslog | grep "MULTI_sva" | grep "@raymore" >> connection-history.log
  fi
  if test -f /etc/SimpleManager/cons.txt ; then 
  if grep -qwF "MULTI_sva" /etc/SimpleManager/cons.txt ; then
  NEWCONNECTION=$(cat /etc/SimpleManager/cons.txt)
  LogInput="New VPN connection on server! -Details- $NEWCONNECTION "
  sudo bash log "$LogInput"
  python3 send.py "$whBLUE" "$LogInput" "$TIME0"
  fi
  rm /etc/SimpleManager/cons.txt
  fi
done