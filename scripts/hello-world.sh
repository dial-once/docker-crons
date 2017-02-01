#!/bin/sh

# this import the docker env vars
. /root/env

echo "It works!"

# Send notification to Slack
#  SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXXXX
if [ "$SLACK_WEBHOOK_URL" ]; then
	curl -X POST --data-urlencode 'payload={"text": "This is posted to #platform-backups and comes from a bot named Backups."}' ${SLACK_WEBHOOK_URL}
fi