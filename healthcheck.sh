#!/bin/ash
temp_dir="/var/tmp/lets_encrypt"
if [ ! -d "${temp_dir}" ]; then mkdir "${temp_dir}"; fi
for lets_encrypt_domain in ${lets_encrypt_domains}; do
   if [ ! -f "${temp_dir}/${lets_encrypt_domain}.check" ]; then echo "$(date '+%c')" > "${temp_dir}/${lets_encrypt_domain}.check"; fi
   if [ "$(find "${temp_dir}" -mtime +1 -type f -name "${lets_encrypt_domain}.check" 2>/dev/null)" ]; then
      days_until_expiry=99
      days_until_expiry="$(/bin/ash -c "certbot certificates --cert-name ${lets_encrypt_domain} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null)"
      if [ -z "${days_until_expiry}" ]; then
         echo "LetsEncrypt initialising"
         exit 1
      fi
      if [ "${days_until_expiry}" -lt 14 ]; then
         echo "LetsEncrypt certificate for domain ${lets_encrypt_domain} expires in ${days_until_expiry}. Renewal required."
         exit 1
      fi
      echo "$(date '+%c')" > "${temp_dir}/${lets_encrypt_domain}.check"
   fi
done
echo "All LetsEncrypt domain certificates valid for more than 20 days. Daily check completed at $(cat "${temp_dir}/${lets_encrypt_domain}.check")"
exit 0