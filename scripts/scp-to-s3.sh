#!/bin/sh
# SCP script to make a remote folder sent to AWS S3!
#
# # # # # # #
# Env vars  #
# # # # # # #
# - SCP_HOST - server hostname
# - SCP_PORT - server port
# - SCP_USER - server username
# - SCP_PASS - server password
# - SCP_FOLDER - server folder
# - SCP_S3_BUCKET - s3 bucket name
# - SCP_S3_REGION - s3 region name

# this import the docker env vars
. /root/env

[ -z "$SCP_FOLDER" ] && exit;

mkdir -p /data/scp/backup
cd /data/scp

archive_name=$SCP_HOST.$(date +"%m_%d_%Y")
echo "Archive name: $archive_name.tar.gz"

expect -c "  
   set timeout 1
   spawn scp -P $SCP_PORT -r -o \"StrictHostKeyChecking no\" $SCP_USER@$SCP_HOST:$SCP_FOLDER backup/
   expect yes/no { send yes\r ; exp_continue }
   expect password: { send $SCP_PASS\r }
   expect 100%
   sleep 600
   exit
" 

tar -zcvf $archive_name.tar.gz backup/

if aws s3 cp $archive_name.tar.gz "s3://$SCP_S3_BUCKET/$archive_name.gz" --region $SCP_S3_REGION; then
	echo "Upload to S3 succeeded"
else
	err_message=$err_message" Upload to S3 failed"
	echo $err_message
fi

archive_length=$(stat -c%s "$archive_name.tar.gz")
echo "Archive size: $archive_length"

rm $archive_name.tar.gz
rm -rf backup/

# Send notification to Slack
#  SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXXXX
if [ "$SLACK_WEBHOOK_URL" ]; then
	curl -X POST --data-urlencode 'payload={"text": "SCP backup succeed. `'$archive_name.tar.gz' '$archive_length'`"}' ${SLACK_WEBHOOK_URL}
fi