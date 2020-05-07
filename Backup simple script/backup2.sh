#!/bin/bash
dpkg -l > /root/backup/dpkg.log

cd /root/backup/
project_etc_tar=$(date +%s)_project.etc.tar.gz
project_www_tar=$(date +%s)_project.www.tar.gz
project_sql_tar=$(date +%s)_project.sql.tar.gz
tar -zcf $project_etc_tar /etc
tar -zcf $project_www_tar /var/www/html/site

export MYDB=postgresql://postgres:passL@127.0.0.1:5432/database
pg_dump --dbname=$MYDB > dump.sql
tar -czvf $project_sql_tar dump.sql
rm dump.sql

files_to_upload="
dpkg.log
$project_etc_tar
$project_files_tar
$project_www_tar
$project_sql_tar
"
for file in $files_to_upload; do
	scp $file root@31.2.3.4:/root/backup
	echo $(date) $file backuping done
done

# remove older backups
find /root/backup/ -type f -name '*project.*' -mtime +15 -delete
rm dpkg.log
