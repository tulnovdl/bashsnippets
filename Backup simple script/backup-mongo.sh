#!/bin/bash
cd /root/backup/

project_landing=$(date +%F-%H_%M)_project_landing.tar.gz
project_etc=$(date +%F-%H_%M)_project_etc.tar.gz
project_wallet_mysql_files=$(date +%F-%H_%M)_project_wallet_mysql_files.tar.gz
project_wallet_mysql_sql=$(date +%F-%H_%M)_project_wallet_mysql.tar.gz
project_bot_back=$(date +%F-%H_%M)_project_bot_back.tar.gz
project_bot_back_mysql_sql=$(date +%F-%H_%M)_project_bot_back_mysql_sql.tar.gz
project_bigdipper_dump=$(date +%F-%H_%M)_project_bigdipper_dump.tar.gz
project_explorer_new_dump=$(date +%F-%H_%M)_project_explorer_new_dump.tar.gz


tar -zcf $project_landing /var/www/project-project.com
tar -zcf $project_etc /etc/
tar -zcf $project_wallet_mysql_files /opt/project_back/var/docker/mysql/
docker-compose --project-directory /opt/project_back -f /opt/project_back/docker-compose.yml exec -T mysql mysqldump -p<password> app >> app.sql
tar -zcf $project_wallet_mysql_sql app.sql
tar -zcf $project_bot_back /opt/project_bot_back
docker-compose --project-directory /opt/project_bot_back -f /opt/project_bot_back/docker-compose.yml exec -T mysql mysqldump -p<password> app_project_bot >> project_bot_back.sql
tar -zcf $project_bot_back_mysql_sql project_bot_back.sql

### old-explorer
containerId=$(docker ps | grep project_big-dipper_mongo_1 | awk '{ print $1 }' )
docker exec $containerId mongodump --out=/root/backup
docker cp $containerId:/root/backup/ /root/backup/backup
docker exec $containerId rm -rf /root/backup
tar -zcf $project_bigdipper_dump backup

### new explorer
containerId=$(docker ps | grep project-new-explorer_mongo_1 | awk '{ print $1 }' )
docker exec $containerId mongodump --out=/root/backup
docker cp $containerId:/root/backup/ /root/backup/mongodump
docker exec $containerId rm -rf /root/backup
tar -zcf $project_explorer_new_dump mongodump


s3cmd put $project_landing s3://projectbackupsqq/web/
s3cmd put $project_wallet_mysql_files s3://projectbackupsqq/web/
s3cmd put $project_wallet_mysql_sql s3://projectbackupsqq/web/
s3cmd put $project_etc s3://projectbackupsqq/web/
s3cmd put $project_bot_back s3://projectbackupsqq/web/
s3cmd put $project_bot_back_mysql_sql s3://projectbackupsqq/web/
s3cmd put $project_bigdipper_dump s3://projectbackupsqq/web/
s3cmd put $project_explorer_new_dump s3://projectbackupsqq/web/

rm $project_landing
rm $project_etc
rm $project_wallet_mysql_files
rm $project_wallet_mysql_sql
rm app.sql
rm $project_bot_back
rm $project_bot_back_mysql_sql
rm project_bot_back.sql
rm -rf /root/backup/backup
rm -rf /root/backup/mongodump
rm $project_bigdipper_dump
rm $project_explorer_new_dump

#s3cmd ls s3://projectbackupsqq/web/ | head -n8 | awk '{ print $4 }' | xargs s3cmd rm
