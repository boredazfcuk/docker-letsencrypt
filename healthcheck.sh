#!/bin/ash
for lets_encrypt_domain in ${lets_encrypt_domains}; do
   days_until_expiry=99
   days_until_expiry="$(/bin/ash -c "certbot certificates --cert-name ${lets_encrypt_domain} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null)"
   if [ -z "${days_until_expiry}" ]; then
      echo "LetsEncrypt initialising"
      exit 1
   fi
   if [ "${days_until_expiry}" -lt 20 ]; then
      echo "LetsEncrypt certificate for domain ${lets_encrypt_domain} expires in ${days_until_expiry}. Renewal required."
      exit 1
   fi
done
echo "All LetsEncrypt domain certificates valid for more than 20 days"
exit 0