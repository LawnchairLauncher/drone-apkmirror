FROM alpine

RUN apk --no-cache add \
        bash \
        curl \
        openssl \
        mailx

ADD upload.sh /bin/
RUN chmod +x /bin/upload.sh

ENTRYPOINT /bin/upload.sh
