#!/bin/bash
#Global Variables##
cd /etc/SimpleManager/
source global.var


cat /var/log/syslog | grep "MULTI_sva: pool returned" > x.txt

##Child Script Variables##
##
LogInput="VPN Logger script is now online."
sudo bash log "$LogInput"
python3 send.py "$whGREEN" "$LogInput" "$TIME0"
VPNLOG1="$(wc -l < /var/log/syslog)"
while [[ "0" = "0" ]]; do     #This is my lazy way of making sure that the script is constantly looping.
sleep 10;                     #This puts a delay on how fast the script can run, this stops the script from overloading your server.
VPNLOG2="$(wc -l < /var/log/syslog)"
  if [[ "$VPNLOG2" > "$VPNLOG1" ]]; then    
  NEWLINES=$((VPN2-VPNLOG1))
  tail -$NEWLINES /var/log/syslog | grep 'MULTI_sva: pool returned' >> cons.txt
  tail -$NEWLINES /var/log/syslog | grep 'MULTI_sva: pool returned' >> connection-history.log
  fi
  if test -f /etc/SimpleManager/cons.txt ; then 
  if grep -qwF "MULTI_sva:" /etc/SimpleManager/cons.txt ; then
  NEWCONNECTION=$(cat /etc/SimpleManager/cons.txt)
  LogInput="New VPN connection on server! -Details- $NEWCONNECTION "
  sudo bash log "$LogInput"
  python3 send.py "$whBLUE" "$LogInput" "$TIME0"
  fi
  rm /etc/SimpleManager/cons.txt
  fi
  VPNLOG1="$(wc -l < /var/log/syslog)"
done