FROM alpine

RUN apk --no-cache add \
        bash \
        curl \
        openssl

ADD upload.sh sendmail /bin/
RUN chmod +x /bin/*.sh /bin/sendmail

ENTRYPOINT /bin/upload.sh
