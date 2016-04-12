#!/bin/sh
# MONGO script to make a MongoDB dump and send all of this to AWS S3!
# Requires MongoDB 3.2 (gzip mongodump)
#
# # # # # # #
# Env vars  #
# # # # # # #
# - MONGO_DB_NAME - mongodb database to MONGO
# - MONGO_DB_USER - mongodb username to login
# - MONGO_DB_PASS - mongodb db password to login
# - MONGO_DB_HOST - mongodb hostname
# - MONGO_S3_BUCKET - s3 bucket name
# - MONGO_S3_REGION - s3 region name
# 

# this import the docker env vars
. /root/env

[ -z "$MONGO_DB_NAME" ] && exit;

mkdir -p /data
cd /data

archive_name=$MONGO_DB_NAME.$(date +"%m_%d_%Y").tar.gz
echo "Archive name: $archive_name"

mongodump --db $MONGO_DB_NAME -h $MONGO_DB_HOST -u $MONGO_DB_USER -p $MONGO_DB_PASS

tar -zcvf $archive_name dump

archive_length=$(stat -c%s "$archive_name")
echo "Archive size: $archive_length"

aws s3 cp $archive_name "s3://$MONGO_S3_BUCKET/$archive_name" --region $MONGO_S3_REGION

rm $archive_name
rm -rf dump
