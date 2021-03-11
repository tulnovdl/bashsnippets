#!/bin/bash

cd /root/backup/
site_sql_tar=$(date +%s).site.sql.tar.gz
site_files_tar=$(date +%s).site_files.tar.gz
site_etc_tar=$(date +%s).site_etc.tar.gz

mysqldump --all-databases > site.sql

tar -czf $site_sql_tar site.sql
tar -czf $site_files_tar /var/www/
tar -czf $site_etc_tar /etc
rm site.sql

files_to_upload="
$site_sql_tar
$site_files_tar
$site_etc_tar
"

HOST="ip"
USER="login"
PASS="pass"
FTPURL="ftp://$USER:$PASS@$HOST"
LCD="/root/backup"
RCD="/remote/path"
LFTP=`which lftp`

STORE_DAYS=3

for file in $files_to_upload; do
    lftp -c "set ftp:list-options -a;
    open '$FTPURL';
    lcd $LCD;
    cd $RCD;
    put $file"
	echo $(date) $file backuping done
done

function removeOlderThanDays() {

    LIST=`mktemp`
    DELLIST=`mktemp`

${LFTP} << EOF
open ${USER}:${PASS}@${HOST}
cd ${RCD}
cache flush
cls -q -1 --date --time-style="+%Y%m%d" > ${LIST}
quit
EOF

    STORE_DATE=$(date -d "now - ${STORE_DAYS} days" '+%Y%m%d')
    while read LINE; do
        if [[ ${STORE_DATE} -ge ${LINE:0:8} && "${LINE}" != *\/ ]]; then
            echo "rm -f \"${LINE:9}\"" >> ${DELLIST}
            echo "${LINE:9} ${LINE:0:8} will be deleted"
        fi
    done < ${LIST}
    if [ ! -f ${DELLIST}  ] || [ -z "$(cat ${DELLIST})" ]; then
        echo "Delete list doesn't exist or empty, nothing to delete. Exiting"
    fi

${LFTP} << EOF
open ${USER}:${PASS}@${HOST}
cd ${RCD}
$(cat ${DELLIST})
quit
EOF
rm ${LIST} ${DELLIST}
}

removeOlderThanDays

find /root/backup/ -type f -name '*tar.gz' -mtime +3 -delete
