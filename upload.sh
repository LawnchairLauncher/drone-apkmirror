#!/bin/bash

if [ -z "$MAJOR_MINOR" ]; then
    MAJOR_MINOR="alpha"
fi

if [ -z "$PLUGIN_APK_PATH" ]; then
    PLUGIN_APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
fi

if [ -z "$PLUGIN_MAPPING_PATH" ]; then
    PLUGIN_MAPPING_PATH="app/build/outputs/mapping/debug/mapping.txt"
fi

if [ -z "$PLUGIN_FILENAME" ]; then
    PLUGIN_FILENAME="Lawnchair"
fi

if [ -z "$PLUGIN_CHANNEL_ID" ]; then
    PLUGIN_CHANNEL_ID="-1001180711841"
fi

if [ -z "$PLUGIN_MAIL_SENDER" ]; then
    PLUGIN_MAIL_SENDER="Lawnchair CI"
fi

if [ -z "$PLUGIN_MAIL_FROM" ]; then
    PLUGIN_MAIL_FROM="buildbot@lawnchair.info"
fi

# Fix dashes in MAJOR_MINOR to not break tags
MAJOR_MINOR=$(echo "${MAJOR_MINOR}" | sed -r 's/-/_/g')

# Adding body to changelog (intentional whitespace!!)
CHANGELOG=" Changelog for build ${MAJOR_MINOR}-${DRONE_BUILD_NUMBER}:
$(cat changelog.txt)"

# Preparing files to upload
cp $PLUGIN_APK_PATH ${PLUGIN_FILENAME}-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk
cp $PLUGIN_MAPPING_PATH proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt

# Obtain nonce
WP_NONCE=$(curl https://www.apkmirror.com | grep -Eow "\"_wpnonce\", '([a-z0-9]+)'" | sed "s/\"_wpnonce\", '//" | sed "s/'//")

FULLNAME="Lawnchair CI (Buildbot)"
EMAIL="buildbot@lawnchair.info"

# Date and time of upload
UPLOAD_DATE=$(date '+%Y-%m-%d at %H:%M:%S')

# Upload it to APKMirror
OUTPUT=$(curl -v \
    -F fullname="$FULLNAME" \
    -F email="$EMAIL" \
    -F changes="$CHANGELOG" \
    -F _wpnonce="$WP_NONCE" \
    -F file=@"${PLUGIN_FILENAME}-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk" \
    https://www.apkmirror.com/wp-content/plugins/UploadManager/inc/upload.php)

# Send curl output via email
sendmail $PLUGIN_MAIL_SENDER $PLUGIN_MAIL_FROM $NOTIFY_EMAIL \
    "[Drone CI] Build #${DRONE_BUILD_NUMBER} uploaded to APKMirror" \
    "This message is to inform that build #${DRONE_BUILD_NUMBER} has been uploaded to APKMirror on $UPLOAD_DATE with result: ${OUTPUT}" \
    $MAIL_SERVER $MAIL_USER $MAIL_PASSWORD
