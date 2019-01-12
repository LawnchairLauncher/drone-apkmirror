FROM alpine

RUN apk --no-cache add \
        bash \
        curl \
        openssl \
        mailx

ADD upload.sh sendmail.sh /bin/
RUN chmod +x /bin/*.sh

ENTRYPOINT /bin/upload.sh
