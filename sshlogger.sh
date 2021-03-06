#!/bin/bash
#Global Variables##
cd /etc/SimpleManager/
source global.var



##Child Script Variables##
##
LogInput="SSH Logger script is now online."
sudo bash log "$LogInput"
python3 send.py "$whGREEN" "$LogInput" "$TIME0"
SSHLOG1="$(wc -l < /var/log/auth.log)"
while [[ "0" = "0" ]]; do     #This is my lazy way of making sure that the script is constantly looping.
sleep 20;                     #This puts a delay on how fast the script can run, this stops the script from overloading your server.
SSHLOG2="$(wc -l < /var/log/auth.log)"
  if [[ "$SSHLOG2" > "$SSHLOG1" ]]; then     
  NEWLINES=$((SSHLOG2-SSHLOG1))
  tail -$NEWLINES /var/log/auth.log | grep 'Accepted' >> auth.txt
  fi
  if test -f /etc/SimpleManager/auth.txt ; then 
  if grep -qwF "Accepted" /etc/SimpleManager/auth.txt ; then
  NEWCONNECTION=$(cat /etc/SimpleManager/auth.txt)
  LogInput="New connection on server! -Details- $NEWCONNECTION "
  sudo bash log "$LogInput"
  python3 send.py "$whBLUE" "$LogInput" "$TIME0"
  fi
  sudo rm -Rf /etc/SimpleManager/auth.txt
  fi
  SSHLOG1="$(wc -l < /var/log/auth.log)"
done