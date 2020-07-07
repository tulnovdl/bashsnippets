#!/bin/bash

cd /root/backup/
project_etc_tar=$(date +%F-%H_%M)_project.etc.tar.gz
project_files_tar=$(date +%F-%H_%M)_project.files.tar.gz
project_sql_tar=$(date +%F-%H_%M)_project.sql.tar.gz

tar --exclude='/etc/httpd/vhost_logs'  --exclude='/etc/nginx/vhost_logs' -zcf $project_etc_tar /etc 
tar -zcf $project_files_tar /home/admin/sites/project.ru

mysqldump -u root -p1asd234POvnZ database > project.sql	
tar -czf $project_sql_tar project.sql
rm project.sql

files_to_upload="
$project_etc_tar
$project_files_tar
$project_sql_tar
"
zip_name=$(date +%F-%H_%M)_backup.zip
zip -r $zip_name $project_etc_tar $project_files_tar $project_sql_tar

rclone copy $zip_name drive:/Archive
echo $(date +%F-%H_%M) $zip_name backuping done

# for file in $files_to_upload; do
# 	rclone copy $file drive:/Archive
# 	echo $(date +%F-%H_%M) $file backuping done
# done

counter=0
for file in $(rclone lsf drive:Archive/); do
	#rclone copy $file drive:/Archive
	counter=$((counter + 1))
	if [ $counter -gt 8 ]; then
    	rclone delete drive:Archive/$file
		echo "deleting $file because older than 7 days"
	else
		echo "not deleting $file"
	fi
done


# remove older backups
find /root/backup/ -type f -name '*project.*' -mtime +15 -delete
