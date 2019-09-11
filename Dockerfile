FROM alpine:latest
MAINTAINER boredazfcuk
ENV CONFIGDIR="/etc/letsencrypt" \
   APPDEPENDENCIES="curl tzdata certbot certbot-nginx nginx nano"

COPY update-certificates.sh /usr/local/bin/update-certificates.sh

RUN echo -e "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD STARTED *****"
echo "$(date '+%d/%m/%Y - %H:%M:%S') | Install application dependencies" && \
   apk add --no-cache --no-progress ${APPDEPENDENCIES} && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | Set permissions on launch script" && \
   chmod 700 "/usr/local/bin/update-certificates.sh" && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD COMPLETE *****"

HEALTHCHECK --start-period=10s --interval=1m --timeout=10s \
  CMD (if [ $(/bin/ash -c "certbot certificates --cert-name ${DOMAIN} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null) -lt 20 ]; then exit 1; fi)

VOLUME "${CONFIGDIR}"

CMD /usr/local/bin/update-certificates.sh && /usr/sbin/crond -f -L /dev/stdout