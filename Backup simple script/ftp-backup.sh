#!/bin/bash    
HOST="212.1.1.1"
USER="user"
PASS="pass"
FTPURL="ftp://$USER:$PASS@$HOST"
LCD="/home"
RCD="/2020/home"
#DELETE="--delete"
lftp -c "set ftp:list-options -a;
open '$FTPURL';
lcd $LCD;
cd $RCD;
mirror --reverse \
       $DELETE \
       --verbose \
       --exclude-glob a-dir-to-exclude/ \
       --exclude-glob a-file-to-exclude \
       --exclude-glob a-file-group-to-exclude* \
       --exclude-glob other-files-to-exclude"
