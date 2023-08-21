#!/bin/bash

# Replace with your Slack webhook URL stored in GitHub secrets
SLACK_WEBHOOK_URL=$SLACK_WEBHOOK_URL_SECRET

# List of domains to check (separate them with spaces)
DOMAINS="example1.com example2.com example3.com"

for DOMAIN in $DOMAINS; do
    EXPIRY_DATE=$(openssl s_client -connect $DOMAIN:443 -servername $DOMAIN -showcerts < /dev/null 2>/dev/null | openssl x509 -enddate -noout | awk -F'=' '{print $2}')
    EXPIRY_UNIX=$(date -d "$EXPIRY_DATE" +%s)
    CURRENT_UNIX=$(date +%s)
    DAYS_LEFT=$(( ($EXPIRY_UNIX - $CURRENT_UNIX) / 86400 ))
    
    MESSAGE="SSL Expiry Alert\n* Domain: $DOMAIN\n* Warning: The SSL certificate for $DOMAIN will expire in $DAYS_LEFT days."
    
    # Send alert to Slack
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$MESSAGE\"}" $SLACK_WEBHOOK_URL
done
