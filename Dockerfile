FROM alpine:latest
MAINTAINER boredazfcuk
ENV CONFIGDIR="/etc/letsencrypt" \
   APPDEPENDENCIES="tzdata certbot certbot-nginx nginx"

COPY update-certificates.sh /usr/local/bin/update-certificates.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh

RUN echo -e "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD STARTED *****" && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | Install application dependencies" && \
   apk add --no-cache --no-progress ${APPDEPENDENCIES} && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | Set permissions on launch script" && \
   chmod 700 /usr/local/bin/update-certificates.sh && \
   chmod +x /usr/local/bin/healthcheck.sh && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD COMPLETE *****"

VOLUME "${CONFIGDIR}"

CMD /usr/local/bin/update-certificates.sh && /usr/sbin/crond -f -L /dev/stdout