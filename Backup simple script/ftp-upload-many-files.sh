#!/bin/bash

cd /root/backup/
formul_sql_tar=$(date +%s)_formul.sql.tar.gz

mysqldump formul > formul.sql
tar -czvf $formul_sql_tar formul.sql
rm *formul*.sql

files_to_upload="
$formul_sql_tar
"

for file in $files_to_upload; do
	  HOST="212.1.1.1"
    USER="user"
    PASS="pass"
    FTPURL="ftp://$USER:$PASS@$HOST"
    LCD="/root/backup"
    RCD="/2020/database"
    lftp -c "set ftp:list-options -a;
    open '$FTPURL';
    lcd $LCD;
    cd $RCD;
    put $file"
	echo $(date) $file backuping done
done


# remove older backups
find /root/backup/ -type f -name '*formul.tar.gz' -mtime +15 -delete
