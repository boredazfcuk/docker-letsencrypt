#!/bin/ash

##### Functions #####
Initialise(){
   echo -e "\n"
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    ***** Starting Let's Encrypt container *****"
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Initialise variables and working folders"
   if [ ! -d /run/nginx ]; then mkdir -p /run/nginx; fi

   if [ -z "${lets_encrypt_domains}" ]; then echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR:   Domain(s) not set, exiting"; exit 1; fi
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certificates directory: ${certificates_path:=${config_dir}/live/}"
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certificate renewal options: ${lets_encrypt_renewal_options:=--standalone}"

   if [ -f "/etc/crontabs/root" ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Initialise crontab"
      minute=$(((RANDOM%60)))
      echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certificates will be renewed at 5:${minute} every day, if required"
      {
         echo "# min   hour    day     month   weekday command"
         echo "${minute} 5 * * * /usr/local/bin/update-certificates.sh --update-only >/dev/stdout 2>&1"
      } > /tmp/crontab.tmp
      crontab /tmp/crontab.tmp
      rm /tmp/crontab.tmp
   fi
}

LaunchCertbot(){
   for lets_encrypt_domain in ${lets_encrypt_domains}; do
      if [ -d "${certificates_path}/${lets_encrypt_domain}" ]; then
         certbot_action="renew"
         echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Domain: $lets_encrypt_domain - $(/bin/ash -c "certbot certificates --cert-name ${lets_encrypt_domain} | grep Expiry | sed 's/^    //g'" 2>/dev/null)"
         days_until_expiry="$(/bin/ash -c "certbot certificates --cert-name ${lets_encrypt_domain} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null)"
         if [ "${days_until_expiry}" -lt 20 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certbot ${certbot_action} certificate"
            /usr/bin/certbot "${certbot_action}" ${lets_encrypt_renewal_options} "-d ${lets_encrypt_domain}" ${dry_run} ${force}
         else
            echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certificate renewal for domain ${lets_encrypt_domain} not required"
         fi
      else
         certbot_action="certonly"
         echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Certbot ${certbot_action} certificate"
         /usr/bin/certbot "${certbot_action}" --webroot -w "/etc/letsencrypt/www" ${lets_encrypt_renewal_options} "-d ${lets_encrypt_domain}" ${dry_run} ${force}
      fi
   done
}

LaunchCrontab(){
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Starting crontab"
   exec /usr/sbin/crond -f -L /dev/stdout
}

##### Script #####
Initialise
if [ $# -eq 0 ]; then
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Check if certificates need an update"
   LaunchCertbot
   LaunchCrontab
elif  [ $# -eq 1 ]; then
   for command_line_parameter in "$@"; do
      case "$command_line_parameter" in
         --dry-run)
            dry_run="--dry-run --debug"
            LaunchCertbot
            ;;
         --force)
            force="--force"
            LaunchCertbot
            ;;
         --update-only)
            LaunchCertbot
            ;;
         *)
            LaunchCrontab
            ;;
      esac
   done
else
   echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    Syntax Error - Too many options"
   exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') INFO:    ***** LetsEncrypt Update Complete *****"
