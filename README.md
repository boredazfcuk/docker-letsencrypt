# docker-letsencrypt
An Alpine Linux Docker container for renewing Lets Encrypt certificates

## HARDCODED VARIABLES

CONFIGDIR: This variable is hardcoded in the dockerfile as /etc/letsencrypt. All mentions of ${CONFIGDIR} beneath refer to the /etc/letsencrypt directory

## MANDATORY VARIABLES

DOMAIN: This is the primary domain name of the certificate to renew. It will match the name of the ${CONFIGDIR}/live/<DOMAIN> directory.

## OPTIONAL VARIABLES

CERTIFICATESPATH: This is the directory where your certificates are stored. If this is not set, it will default to ${CONFIGDIR}/live/${DOMAIN}/

RENEWALOPTIONS: This are any additional renewal options that you wish to pass to the certbot command. If it is not set, it will default to '--standalone'

## COMMAND-LINE PARAMETERS

The /usr/bin/update-certificates.sh script accepts two command line parameters:

```
   --dry-run
   --force
```

If you have made changes to your certificates and want to make sure that they will renew correctly, run the script as follows:

```
   /usr/local/bin/update-certificates.sh --dry-run
```

If you are happy with the changes, or if you just want to force an update outside of the 20-day renewal period, you can run the command as follows:

```
   /usr/local/bin/update-certificates.sh --force
```

This container will also create a crontab entry to run the certificate update function between 4-5am on Thursday mornings. I have randomised the minute so different installs will connect to the upstream servers at diffent times.
