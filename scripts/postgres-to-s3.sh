#!/bin/sh
# Postgres script to make a MongoDB dump and send all of this to AWS S3!
#
# # # # # # #
# Env vars  #
# # # # # # #
# - POSTGRES_HOST - postgres hostname
# - POSTGRES_PORT - postgres port
# - POSTGRES_DB - postgres database name
# - POSTGRES_USER - postgres username to login
# - POSTGRES_PASS - postgres db password to login
# - POSTGRES_S3_BUCKET - s3 bucket name
# - POSTGRES_S3_REGION - s3 region name

# this import the docker env vars
. /root/env

[ -z "$POSTGRES_DB" ] && exit;

export PGPASSWORD=$POSTGRES_PASS

mkdir -p /data
cd /data

archive_name=$POSTGRES_DB.$(date +"%m_%d_%Y")
echo "Archive name: $archive_name.gz"

if pg_dumpall --host=$POSTGRES_HOST --port=$POSTGRES_PORT --database=$POSTGRES_DB --username=$POSTGRES_USER --file $archive_name --no-password; then
	echo "PostgreSQL dump succeeded"
else
	err_message+="PostgreSQL dump failed "
	echo $err_message
fi

gzip $archive_name

if aws s3 cp $archive_name.gz "s3://$POSTGRES_S3_BUCKET/$archive_name.gz" --region $POSTGRES_S3_REGION; then
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
		curl -X POST --data-urlencode 'payload={"text": "PostgreSQL backup failed: '"$err_message"'"}' ${SLACK_WEBHOOK_URL}
	else
		curl -X POST --data-urlencode 'payload={"text": "PostgreSQL backup succeed. `'$archive_name.gz' '$archive_length'`"}' ${SLACK_WEBHOOK_URL}
	fi
fi