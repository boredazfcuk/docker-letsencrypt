#FROM alpine:3.12
FROM alpine:3.14
MAINTAINER boredazfcuk
ARG app_dependencies="tzdata certbot"
ENV config_dir="/etc/letsencrypt"

RUN echo -e "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD STARTED FOR LETSENCRYPT *****" && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | Install application dependencies" && \
   apk add --no-cache --no-progress ${app_dependencies}

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh

RUN echo "$(date '+%d/%m/%Y - %H:%M:%S') | Set permissions on launch script" && \
   chmod 700 /usr/local/bin/entrypoint.sh && \
   chmod +x /usr/local/bin/healthcheck.sh && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD COMPLETE *****"

VOLUME "${config_dir}"

ENTRYPOINT /usr/local/bin/entrypoint.sh