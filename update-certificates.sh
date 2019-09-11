#!/bin/ash

##### Functions #####
Initialise(){
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    ***** Starting Let's Encrypt container *****"
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Initialise variables and working folders"
   if [ ! -d /run/nginx ]; then mkdir -p /run/nginx; fi

   if [ -z "${DOMAIN}" ]; then echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR:    Domain not set, exiting"; exit 1; fi
   if [ -z "${CERTIFICATESPATH}" ]; then echo "$(date '+%Y-%m-%d %H:%M:%S') WARNING: Certificate path not specified, defaulting to ${CONFIGDIR}/live/${DOMAIN}/"; CERTIFICATESPATH="${CONFIGDIR}/live/${DOMAIN}/"; fi
   if [ -z "${RENEWALOPTIONS}" ]; then echo "$(date '+%Y-%m-%d %H:%M:%S') WARNING: Renewal options not set, defaulting to '--standalone'"; RENEWALOPTIONS="--standalone"; fi

   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certificates directory: ${CERTIFICATESPATH}"
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certificate renewal options: ${RENEWALOPTIONS}"

   if [ $(grep -c "update-letsencrypt.sh" /etc/crontabs/root) -lt 1 ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Initialise crontab"
      MIN=$(((RANDOM%60)))
      echo -e "# min   hour    day     month   weekday command\n${MIN} 5 * * 4 /usr/local/bin/update-letsencrypt.sh" > /tmp/crontab.tmp
      crontab /tmp/crontab.tmp
      rm /tmp/crontab.tmp
   fi

}

CheckCertificates(){
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    $(/bin/ash -c "certbot certificates --cert-name ${DOMAIN} | grep Expiry | sed 's/^    //g'" 2>/dev/null)"
   AGE=$(/bin/ash -c "certbot certificates --cert-name ${DOMAIN} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null)
   if [ "${AGE}" -lt 20 ]; then
      UpdateCertificates
   fi
}

ForceUpdateCertificates(){
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Force certificates renewal"
   /usr/bin/certbot renew "${RENEWALOPTIONS}" --force
}

TestUpdateCertificates(){
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Test certificates renewal"
   /usr/bin/certbot renew "${RENEWALOPTIONS}" --dry-run
}

UpdateCertificates(){
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Renew certificates"
   /usr/bin/certbot renew "${RENEWALOPTIONS}"
}

##### Script #####
Initialise
if [ $# -eq 0 ]; then
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Check if certificates need an update"
   CheckCertificates
elif  [ $# -eq 1 ]; then
   for Option in "$@"
   do
      case $Option in
         --force)
            ForceUpdateCertificates
            ;;
         --dry-run)
            TestUpdateCertificates
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
