#!/bin/sh
# SCP script to make a remote folder sent to AWS S3!
#
# # # # # # #
# Env vars  #
# # # # # # #
# - SCP_HOST - 
# - SCP_USER - 
# - SCP_FOLDER -
# - SCP_PASSWORD -
# - SCP_PORT -
# - SCP_S3_BUCKET - 
# - SCP_S3_REGION -

# this import the docker env vars
. /root/env

[ -z "$SCP_FOLDER" ] && exit;

mkdir -p /data/scp/backup
cd /data/scp

archive_name=$SCP_HOST.$(date +"%m_%d_%Y")
echo "Archive name: $archive_name"

expect -c "  
   set timeout 1
   spawn scp -P $SCP_PORT -r -o \"StrictHostKeyChecking no\" $SCP_USER@$SCP_HOST:$SCP_FOLDER backup/
   expect yes/no { send yes\r ; exp_continue }
   expect password: { send $SCP_PASSWORD\r }
   expect 100%
   sleep 600
   exit
" 

tar -zcvf $archive_name.tar.gz backup/

aws s3 cp $archive_name.tar.gz "s3://$SCP_S3_BUCKET/$archive_name.gz" --region $SCP_S3_REGION

rm $archive_name.tar.gz
rm -rf backup/
