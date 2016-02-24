#!/bin/sh
# Postgres script to make a MongoDB dump and send all of this to AWS S3!
#
# # # # # # #
# Env vars  #
# # # # # # #
# - POSTGRES_DB - postgres database name
# - POSTGRES_PASSWORD - 
# - POSTGRES_USER - 
# - POSTGRES_HOST - 
# - POSTGRES_PORT - 
# - POSTGRES_S3_REGION
# - POSTGRES_S3_BUCKET

# this import the docker env vars
. /root/env

[ -z "$POSTGRES_DB" ] && exit;

export PGPASSWORD=$POSTGRES_PASSWORD

mkdir -p /data
cd /data

archive_name=$POSTGRES_DB.$(date +"%m_%d_%Y")
echo "Archive name: $archive_name"

pg_dumpall --host=$POSTGRES_HOST --port=$POSTGRES_PORT --database=$POSTGRES_DB --username=$POSTGRES_USER --file $archive_name --no-password

gzip $archive_name

aws s3 cp $archive_name.gz "s3://$POSTGRES_S3_BUCKET/$archive_name.gz" --region $POSTGRES_S3_REGION

rm $archive_name
rm $archive_name.gz
