#!/bin/bash
dpkg -l > /root/backup/dpkg_zabbix.log

cd /root/backup/
zabbix_etc_tar=$(date +%s)_zabbix.etc.tar.gz
zabbix_files_tar=$(date +%s)_zabbix.files.tar.gz
zabbix_lib_tar=$(date +%s)_zabbix.lib.tar.gz
zabbix_sql_tar=$(date +%s)_zabbix.sql.tar.gz
tar -zcf $zabbix_etc_tar /etc
tar -zcf $zabbix_files_tar /usr/share/zabbix
tar -zcf $zabbix_lib_tar /usr/lib/zabbix/externalscripts

mysqldump -u root -ppass zabbix > zabbix.sql
tar -czvf $zabbix_sql_tar zabbix.sql
rm *zabbix*.sql

files_to_upload="
dpkg_zabbix.log
$zabbix_etc_tar
$zabbix_files_tar
$zabbix_lib_tar
$zabbix_sql_tar
"
for file in $files_to_upload; do
	ftp-upload -h qnap1.domain.local -u zabbix_user --password pass -d DirPath $file
	echo $(date) $file backuping done
done

# remove older backups
find /root/backup/ -type f -name '*zabbix.*' -mtime +15 -delete
rm dpkg_zabbix.log