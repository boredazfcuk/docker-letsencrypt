#!/bin/ash
for DOMAIN in ${LETSENCRYPTDOMAINS}; do
   EXPIRY_DAYS=99
   EXPIRY_DAYS="$(/bin/ash -c "certbot certificates --cert-name ${DOMAIN} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null)"
   if [ -z "${EXPIRY_DAYS}" ]; then
      echo "LetsEncrypt initialising"
      exit 1
   fi
   if [ "${EXPIRY_DAYS}" -lt 20 ]; then
      echo "LetsEncrypt certificate for domain ${DOMAIN} expires in ${EXPIRY_DAYS}. Renewal required."
      exit 1
   fi
done
echo "All LetsEncrypt domain certificates valid for more than 20 days"
exit 0