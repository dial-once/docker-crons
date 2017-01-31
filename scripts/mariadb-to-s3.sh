#!/bin/sh
# MariaDB script to make a MariaDB dump and send all of this to AWS S3!
#
# # # # # # #
# Env vars  #
# # # # # # #
# - MARIADB_HOST - mariadb hostname
# - MARIADB_PORT - mariadb port
# - MARIADB_DB - mariadb database name
# - MARIADB_USER - mariadb username to login
# - MARIADB_PASS - mariadb db password to login
# - MARIADB_S3_BUCKET - s3 bucket name
# - MARIADB_S3_REGION - s3 region name

# this import the docker env vars
. /root/env

[ -z "$MARIADB_DB" ] && exit;

mkdir -p /data
cd /data

archive_name=$MARIADB_DB.$(date +"%m_%d_%Y")
echo "Archive name: $archive_name.gz"

if mysqldump --host=$MARIADB_HOST --port=$MARIADB_PORT --password=$MARIADB_PASS --user=$MARIADB_USER $MARIADB_DB > $archive_name; then
	echo "MariaDB dump succeeded"
else 
	err_message="MariaDB dump failed"
	echo $err_message
fi

gzip $archive_name

if aws s3 cp $archive_name.gz "s3://$MARIADB_S3_BUCKET/$archive_name.gz" --region $MARIADB_S3_REGION; then
	echo "Upload to S3 succeeded"
else
 	err_message=$err_message" Upload to S3 failed"
	echo $err_message
fi

archive_length=$(du -h "$archive_name.gz" | head -n1 | awk '{print $1;}')
echo "Archive size: $archive_length"

rm $archive_name.gz

# Send notification to Slack
#  SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXXXX
if [ "$SLACK_WEBHOOK_URL" ]; then
	if [ "$err_message" ]; then
		curl -X POST --data-urlencode 'payload={"text": "MariaDB backup failed: '"$err_message"'"}' ${SLACK_WEBHOOK_URL}
	else
		curl -X POST --data-urlencode 'payload={"text": "MariaDB backup succeed. `'$archive_name.gz' '$archive_length'`"}' ${SLACK_WEBHOOK_URL}
	fi
fi