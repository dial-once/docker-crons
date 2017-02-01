#!/bin/sh
# MONGO script to make a MongoDB dump and send all of this to AWS S3!
# Requires MongoDB 3.2 (gzip mongodump)
#
# # # # # # #
# Env vars  #
# # # # # # #
# - MONGO_DB_HOST - mongodb hostname
# - MONGO_DB_PORT - mongodb port
# - MONGO_DB_NAME - mongodb database 
# - MONGO_DB_USER - mongodb username to login
# - MONGO_DB_PASS - mongodb db password to login
# - MONGO_S3_BUCKET - s3 bucket name
# - MONGO_S3_REGION - s3 region name
# 

# this import the docker env vars
. /root/env

[ -z "$MONGO_DB_NAME" ] && exit;

mkdir -p /data
cd /data

archive_name=$MONGO_DB_NAME.$(date +"%m_%d_%Y")
echo "Archive name: $archive_name.tar.gz"

appendCmd=""
appendCredentials=""

if [ "$MONGO_EXCLUDE" ]; then appendCmd="--excludeCollection $MONGO_EXCLUDE" ;fi
if [ "$MONGO_DB_USER" ]; then appendCredentials="-u $MONGO_DB_USER -p $MONGO_DB_PASS" ;fi

if mongodump --gzip --host $MONGO_DB_HOST --port $MONGO_DB_PORT --db $MONGO_DB_NAME $appendCredentials $appendCmd; then
	echo "MongoDB dump succeeded"
else
	err_message+="MongoDB dump failed "
	echo $err_message
fi

tar -zcvf $archive_name.tar.gz dump --remove-files

archive_length=$(du -h "$archive_name.tar.gz" | head -n1 | awk '{print $1;}')
echo "Archive size: $archive_length"

if aws s3 cp $archive_name.tar.gz "s3://$MONGO_S3_BUCKET/$archive_name.tar.gz" --region $MONGO_S3_REGION; then
	echo 'Upload to S3 succeeded'
else
	err_message=$err_message" Upload to S3 failed"
	echo $err_message
fi

rm $archive_name.tar.gz
rm -rf dump

# Send notification to Slack
#  SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXXXX
if [ "$SLACK_WEBHOOK_URL" ]; then
	if [ "$err_message" ]; then
		curl -X POST --data-urlencode 'payload={"text": "MongoDB backup failed: '"$err_message"'"}' ${SLACK_WEBHOOK_URL}
	else
		curl -X POST --data-urlencode 'payload={"text": "MongoDB backup succeed. `'$archive_name.gz' '$archive_length'`"}' ${SLACK_WEBHOOK_URL}
	fi
fi