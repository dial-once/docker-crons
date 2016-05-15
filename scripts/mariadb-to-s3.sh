#!/bin/sh
# MariaDB script to make a MariaDB dump and send all of this to AWS S3!
#
# # # # # # #
# Env vars  #
# # # # # # #
# - MARIADB_DB - MARIADB database name
# - MARIADB_PASSWORD - 
# - MARIADB_USER - 
# - MARIADB_HOST - 
# - MARIADB_PORT - 
# - MARIADB_S3_REGION
# - MARIADB_S3_BUCKET

# this import the docker env vars
. /root/env

[ -z "$MARIADB_DB" ] && exit;

mkdir -p /data
cd /data

archive_name=$MARIADB_DB.$(date +"%m_%d_%Y")
echo "Archive name: $archive_name"

mysqldump --host=$MARIADB_HOST --port=$MARIADB_PORT --password=$MARIADB_PASSWORD --user=$MARIADB_USER $MARIADB_DB > $archive_name

gzip $archive_name

aws s3 cp $archive_name.gz "s3://$MARIADB_S3_BUCKET/$archive_name.gz" --region $MARIADB_S3_REGION

rm $archive_name.gz
