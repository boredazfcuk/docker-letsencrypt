#!/bin/ash

##### Functions #####
Initialise(){
   echo
   echo "INFO:    ***** Starting Let's Encrypt container *****"
   echo "INFO:    $(cat /etc/*-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/"//g')"
   echo "INFO:    Initialise variables and working folders"
   if [ ! -d /run/nginx ]; then mkdir -p /run/nginx; fi

   if [ -z "${lets_encrypt_domains}" ]; then echo "ERROR:   Domain(s) not set, exiting"; exit 1; fi
   echo "INFO:    Certificates directory: ${certificates_path:=${config_dir}/live/}"
   echo "INFO:    Certificate renewal options: ${lets_encrypt_renewal_options:=--standalone}"

   if [ -f "/etc/crontabs/root" ]; then
      echo "INFO:    Initialise crontab"
      minute=$(((RANDOM%60)))
      if [ "${#minute}" -eq 1 ]; then minute="0${minute}"; fi
      echo "INFO:    Certificates will be renewed at 5:${minute} every day, if required"
      {
         echo "# min   hour    day     month   weekday command"
         echo "${minute} 5 * * *  /usr/local/bin/letsencrypt-entrypoint.sh --update-only"
      } > /tmp/crontab.tmp
      crontab /tmp/crontab.tmp
      rm /tmp/crontab.tmp
   fi
}

LaunchCertbot(){
   echo "INFO:    Starting LetsEncrypt certificate update procedure for domains: ${lets_encrypt_domains}"
   for lets_encrypt_domain in ${lets_encrypt_domains}; do
      if [ -d "${certificates_path:=${config_dir}/live/}/${lets_encrypt_domain}" ]; then
         echo "INFO:    Domain: ${lets_encrypt_domain} - $(/bin/ash -c "certbot certificates --cert-name ${lets_encrypt_domain} | grep Expiry | sed 's/^    //g'" 2>/dev/null)"
         days_until_expiry="$(/bin/ash -c "certbot certificates --cert-name ${lets_encrypt_domain} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null)"
         if [ "${days_until_expiry}" -lt 20 ]; then
            echo "INFO:    Renewal required for ${lets_encrypt_domain}"
            "$(which certbot)" certonly --webroot -w "/etc/letsencrypt/www" -d "${lets_encrypt_domain}" ${lets_encrypt_renewal_options} ${dry_run} ${force}
            current_cert_name="$(ls -rt /etc/letsencrypt/archive/${lets_encrypt_domain}/cert*.pem | tail -n 1)"
            "$(which md5sum)" "${current_cert_name}" | awk '{print $1}' > "/etc/letsencrypt/archive/${lets_encrypt_domain}/cert.md5"
         else
            echo "INFO:    Certificate renewal for domain ${lets_encrypt_domain} not required"
         fi
      else
         echo "ERROR:   Path does not exist: ${certificates_path}/${lets_encrypt_domain}"
      fi
   done
   echo "INFO:    LetsEncrypt certificate update procedure complete"
}

LaunchCrontab(){
   echo "INFO:    Starting crontab"
   exec /usr/sbin/crond -f -d 7 -L /dev/stdout
}

##### Script #####
if [ $# -eq 0 ]; then
   Initialise
   echo "INFO:    Check if certificates need an update"
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
            echo "ERROR:  Command line parameter not recognised: ${command_line_parameter}"
            echo "ERROR:  Restarting in 5 minutes"  
            sleep 300
            ;;
      esac
   done
else
   echo "INFO:    Syntax Error - Too many options"
   exit 1
fi
