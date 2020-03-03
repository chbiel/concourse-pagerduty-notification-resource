FROM alpine:3.8

LABEL maintainer="Christopher Biel <christopher.biel89@gmail.com>"

ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

RUN apk add --no-cache ca-certificates python3 py3-requests

COPY assets/ /opt/resource/

RUN chmod +x /opt/resource/out /opt/resource/in /opt/resource/check