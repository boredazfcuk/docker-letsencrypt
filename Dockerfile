#FROM alpine:3.12
FROM alpine:3.14
MAINTAINER boredazfcuk
ARG app_dependencies="tzdata certbot"
ENV config_dir="/etc/letsencrypt"

RUN echo -e "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD STARTED FOR LETSENCRYPT *****" && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | Install application dependencies" && \
   apk add --no-cache --no-progress ${app_dependencies} && \
echo "$(date '+%d/%m/%Y - %H:%M:%S') | ***** BUILD COMPLETE *****"

COPY --chmod=0700 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

VOLUME "${config_dir}"

ENTRYPOINT /usr/local/bin/entrypoint.sh
