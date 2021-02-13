#!/bin/bash

cd /root/backup/
siteall_sql_tar=$(date +%s).siteall.sql.tar.gz
siteall_files_tar=$(date +%s).siteall_files.tar.gz
siteall_etc_tar=$(date +%s).siteall_etc.tar.gz

mysqldump --all-databases > siteall.sql

tar -czf $siteall_sql_tar siteall.sql
tar -czf $siteall_files_tar /var/www/
tar -czf $siteall_etc_tar /etc
rm siteall.sql

files_to_upload="
$siteall_sql_tar
$siteall_files_tar
$siteall_etc_tar
"


for file in $files_to_upload; do
    HOST="1.1.76.50"
    USER="acc"
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

ftpsite="1.1.76.50"
ftpuser="acc"
ftppass="pass"
putdir="/backup"

ndays=6

# work out our cutoff date
MM="$(date --date="$ndays days ago" +%b)"
DD="$(date --date="$ndays days ago" +%d)"


echo removing files older than $MM $DD

# get directory listing from remote source
listing=`ftp -i -n $ftpsite <<EOMYF 
user $ftpuser $ftppass
binary
cd $putdir
ls
quit
EOMYF
`
lista=( $listing )
MM=$(tr -dc '0-9' <<< $MM)
DD=$(tr -dc '0-9' <<< $DD)
MM=${MM#0}
DD=${DD#0}
# loop over our files
for ((FNO=0; FNO<${#lista[@]}; FNO+=9));do
  # month (element 5), day (element 6) and filename (element 8)
  #echo Date ${lista[`expr $FNO+5`]} ${lista[`expr $FNO+6`]}          File: ${lista[`expr $FNO+8`]}

  # check the date stamp
  if [ ${lista[`expr $FNO+5`]}=$MM ];
  then
    if [[ "${lista[`expr $FNO+6`]}" -lt $DD ]];
    then
      # Remove this file
      echo "Removing ${lista[`expr $FNO+8`]}"
      ftp -i -n $ftpsite <<EOMYF2 
      user $ftpuser $ftppass
      binary
      cd $putdir
      quit
EOMYF2


    fi
  fi
done

find /root/backup/ -type f -name '*tar.gz' -mtime +1 -delete
