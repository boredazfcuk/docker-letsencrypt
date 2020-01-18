FROM alpine:latest
MAINTAINER boredazfcuk
ARG app_dependencies="tzdata certbot"
ENV config_dir="/etc/letsencrypt"

RUN echo -e "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD STARTED *****" && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | Install application dependencies" && \
   apk add --no-cache --no-progress ${app_dependencies}

COPY update-certificates.sh /usr/local/bin/update-certificates.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh

RUN echo "$(date '+%d/%m/%Y - %H:%M:%S') | Set permissions on launch script" && \
   chmod 700 /usr/local/bin/update-certificates.sh && \
   chmod +x /usr/local/bin/healthcheck.sh && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD COMPLETE *****"

VOLUME "${config_dir}"

CMD /usr/local/bin/update-certificates.sh && /usr/sbin/crond -f -L /dev/stdout