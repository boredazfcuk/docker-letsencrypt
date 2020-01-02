#!/bin/ash

##### Functions #####
Initialise(){
   echo -e "\n"
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    ***** Starting Let's Encrypt container *****"
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Initialise variables and working folders"
   if [ ! -d /run/nginx ]; then mkdir -p /run/nginx; fi

   if [ -z "${LETSENCRYPTDOMAINS}" ]; then echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR:   Domain(s) not set, exiting"; exit 1; fi
   if [ -z "${CERTIFICATESPATH}" ]; then echo "$(date '+%Y-%m-%d %H:%M:%S') WARNING: Certificate path not specified, defaulting to ${CONFIGDIR}/live/"; CERTIFICATESPATH="${CONFIGDIR}/live/"; fi
   if [ -z "${RENEWALOPTIONS}" ]; then echo "$(date '+%Y-%m-%d %H:%M:%S') WARNING: Renewal options not set, defaulting to '--standalone'"; RENEWALOPTIONS="--standalone"; fi

   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certificates directory: ${CERTIFICATESPATH}"
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certificate renewal options: ${RENEWALOPTIONS}"

   if [ "$(grep -c "update-certificates.sh" /etc/crontabs/root)" -lt 1 ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Initialise crontab"
      MIN=$(((RANDOM%60)))
      echo -e "# min   hour    day     month   weekday command\n${MIN} 5 * * 4 /usr/local/bin/update-certificates.sh" > /tmp/crontab.tmp
      crontab /tmp/crontab.tmp
      rm /tmp/crontab.tmp
   fi

}

LaunchCertbot(){
   for DOMAIN in ${LETSENCRYPTDOMAINS}; do
      if [ -d "${CERTIFICATESPATH}/${DOMAIN}" ]; then
         ACTION="renew"
         echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Domain: $DOMAIN - $(/bin/ash -c "certbot certificates --cert-name ${DOMAIN} | grep Expiry | sed 's/^    //g'" 2>/dev/null)"
         AGE="$(/bin/ash -c "certbot certificates --cert-name ${DOMAIN} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null)"
         if [ "${AGE}" -lt 20 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certbot ${ACTION} certificate"
            /usr/bin/certbot "${ACTION}" ${RENEWALOPTIONS} "-d ${DOMAIN}" ${DRYRUN} ${FORCE}
         fi
      else
         ACTION="certonly"
         echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certbot ${ACTION} certificate"
         /usr/bin/certbot "${ACTION}" --webroot -w "/etc/letsencrypt/www" ${RENEWALOPTIONS} "-d ${DOMAIN}" ${DRYRUN} ${FORCE}
      fi
   done
}

##### Script #####
Initialise
if [ $# -eq 0 ]; then
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Check if certificates need an update"
   LaunchCertbot
elif  [ $# -eq 1 ]; then
   for OPTION in "$@"; do
      case "$OPTION" in
         --dry-run)
            DRYRUN="--dry-run --debug"
            LaunchCertbot
            ;;
         --force)
            FORCE="--force"
            LaunchCertbot
            ;;
         *)
            echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Syntax Error - Unknown option"
            exit 1
            ;;
      esac
   done
else
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Syntax Error - Too many options"
   exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    ***** LetsEncrypt Update Complete *****"
