#!/bin/bash
#Global Variables##
source $HOME/SimpleManager/global.var

TIME0=$(date)    
sudo /bin/cat <<-EOM >>$FILE
    Activity logged on $TIME0
	Script Version="$APIVERSION" || Last SSH Connection $SSH_CONNECTION
    ####################################################################################
	${TAB}SERVER: $serverip${TAB}DETECTED ACTIVITY:
	${TAB} $1 
	${TAB} $2 
	${TAB} $3
	${TAB}END
EOM
