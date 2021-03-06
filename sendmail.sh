#!/bin/bash
# Send email via SMTP from bash using curl
# Example: ./sendmail.sh "System admin" admin@localhost buildbot@localhost "Build status" "Build finished with result code 0" "smtps://localhost:465" admin password

SENDER=$1
FROM=$2
TO=$3
SUBJECT=$4
MESSAGE=$5
SERVER=$6
USER=$7
PASSWORD=$8

# Generate message-id
generate_id() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

DOMAIN=$(echo $FROM | cut -d@ -f2)
MESSAGE_ID="<$(generate_id 8).$(generate_id 16)@$DOMAIN>"

# Get current timestamp
DATE=$(date +"%a, %d %b %Y %H:%M:%S %z")

# Output message to temporary file
MAIL=$(mktemp -t mailXXXXXX)
cat << EOF > $MAIL
Date: $DATE
From: $SENDER <$FROM>
To: $TO
Subject: $SUBJECT
Message-ID: $MESSAGE_ID
User-Agent: drone-ci/sendmail.sh
MIME-Version: 1.0
Content-Type: text/plain; charset="utf8"

$MESSAGE
EOF

# Send the mail!
curl --url $SERVER --ssl-reqd --insecure \
    --mail-from $FROM --mail-rcpt $TO \
    --upload-file $MAIL --user "$USER:$PASSWORD"
