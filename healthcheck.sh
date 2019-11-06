#!/bin/ash

if [ $(/bin/ash -c "certbot certificates --cert-name ${DOMAIN} | grep Expiry | cut -d':' -f 6 | sed 's/[^0-9]*//g'" 2>/dev/null) -lt 20 ]; then
   exit 1
fi

exit 0