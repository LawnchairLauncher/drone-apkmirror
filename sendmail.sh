#!/bin/bash
# Send email via SMTP from bash using mailx
# Example: ./sendmail.sh admin@localhost buildbot@localhost "Build status" "Build finished with result code 0" localhost:587 admin password

FROM=$1
RECIPIENT=$2
SUBJECT=$3
MESSAGE=$4
SERVER=$5
USER=$6
PASSWORD=$7

# Output message to temporary file
MAIL=$(tempfile)
echo $MESSAGE > $MAIL

# Send the mail!
mailx -v \
    -r $FROM \
    -s $SUBJECT \
    -S smtp="$SERVER" \
    -S smtp-use-starttls \
    -S smtp-auth=login \
    -S smtp-auth-user="$USER" \
    -S smtp-auth-password="$PASSWORD" \
    -S ssl-verify=ignore \
    $RECIPIENT < $MAIL
