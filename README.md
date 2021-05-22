# docker-letsencrypt
An Alpine Linux Docker container for renewing Lets Encrypt certificates

## HARDCODED VARIABLES

config_dir: This variable is hardcoded in the dockerfile as /etc/letsencrypt. All mentions of ${config_dir} beneath refer to the /etc/letsencrypt directory

## MANDATORY VARIABLES

DOMAIN: This is the primary domain name of the certificate to renew. It will match the name of the ${config_dir}/live/<DOMAIN> directory.

## OPTIONAL VARIABLES

CERTIFICATESPATH: This is the directory where your certificates are stored. If this is not set, it will default to ${config_dir}/live/${DOMAIN}/

lets_encrypt_renewal_options: This are any additional renewal options that you wish to pass to the certbot command. If it is not set, it will default to '--standalone'

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

## CREATING A CONTAINER

```
docker create \
   --name <Container name> \
   --hostname <Hostname of container> \
   --network <Name of Docker network to connect to> \
   --restart <Restart policy> \
   --env DOMAIN=<The primary domain name of the certificate to renew> \
   --env lets_encrypt_renewal_options="<Renewal options to pass to certbot certificate renewal client>" \
   --env TZ=<Your Time Zone> \
   --volume <Named volume or path to host folder>:/etc/letsencrypt/ \
   boredazfcuk/letsencrypt
```

As an example, this is the command I run on my host machine:

```
docker create \
   --name LetsEncrypt \
   --hostname letsencrypt \
   --network containers \
   --restart always \
   --env DOMAIN=thisisnt.reallymydomin.com \
   --env lets_encrypt_renewal_options="--standalone --non-interactive --must-staple --staple-ocsp" \
   --env TZ=Europe/London \
   --volume letsencrypt_config:/etc/letsencrypt/ \
   boredazfcuk/letsencrypt
```

Litecoin: LfmogjcqJXHnvqGLTYri5M8BofqqXQttk4