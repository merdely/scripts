#!/usr/bin/env bash

# To use this script, add to root's crontab:
# 30 5 1,15 * * /usr/local/bin/certbot renew -q --reuse-key --deploy-hook '/srv/scripts/sbin/certbot-deploy-hook.sh'

# Needed for wildcard certs
set -o noglob

# Alias which to 'command -v' if which does not exist
! which which > /dev/null 2>&1 && alias which='command -v'

if which hostname > /dev/null 2>&1; then
  hostname=$(hostname)
else
  hostname=$(hostnamectl hostname)
fi
hostname=${hostname%%.*}

if [ -n "$1" ]; then
  if [ "${1:0:9}" = /etc/acme ]; then
    domain=${1##*/}
    if [ ! -f /etc/acme/$domain/fullchain.cer ]; then
      echo "Error: Cannot find /etc/acme/$domain"
      exit 1
    fi
    CERT_PATH=/etc/acme/$domain/$domain.cer
    CA_CERT_PATH=/etc/acme/$domain/ca.cer
    CERT_FULLCHAIN_PATH=/etc/acme/$domain/fullchain.cer
    CERT_KEY_PATH=/etc/acme/$domain/$domain.key
  elif [ "${1:0:16}" = /etc/letsencrypt ]; then
    domain=${1##*/}
    if [ ! -f /etc/letsencrypt/live/$domain/fullchain.pem ]; then
      echo "Error: Cannot find /etc/letsencrypt/live/$domain"
      exit 1
    fi
    RENEWED_LINEAGE=/etc/letsencrypt/live/$domain
    #CERT_PATH=/etc/letsencrypt/live/$domain/cert.pem
    #CA_CERT_PATH=/etc/letsencrypt/live/$domain/chain.pem
    #CERT_FULLCHAIN_PATH=/etc/letsencrypt/live/$domain/fullchain.pem
    #CERT_KEY_PATH=/etc/letsencrypt/live/$domain/privkey.pem
  else
    echo "usage: $0 [/etc/acme/DOMAINNAME|/etc/letsencrypt/live/DOMAINNAME]"
    exit 1
  fi
fi

[ -z "$CERT_PATH" ] && [ -z "$RENEWED_LINEAGE" ] && echo "Error: CERT_PATH (acme.sh) or RENEWED_LINEAGE (certbot) must be set" && exit 1

# Certbot variables
# By default, certbot runs the command with this variable set
# To run this command manually, run: env RENEWED_LINEAGE=/etc/letsencrypt/live/DOMAINNAME certbot-deploy-hook.sh
# Certbot names wildcard domains as wildcard.domain.com
# $RENEWED_LINEAGE points to /etc/letsencrypt/live/$domain
if [ -n "$RENEWED_LINEAGE" ]; then
  CERT_PATH=$RENEWED_LINEAGE/cert.pem
  CA_CERT_PATH=$RENEWED_LINEAGE/chain.pem
  CERT_FULLCHAIN_PATH=$RENEWED_LINEAGE/fullchain.pem
  CERT_KEY_PATH=$RENEWED_LINEAGE/privkey.pem
  # Set domain to the directory name (cert_name) and substitute "wildcard" for "*"
  config_home=${RENEWED_LINEAGE%/*}
  config_home=${config_home%/*}
  domain=${RENEWED_LINEAGE##*/}
  safe_domain=${RENEWED_LINEAGE##*/}
  safe_domain=${safe_domain//\*/wildcard}
else
  [ -d "$CERT_PATH" ] && [ -f "$CERT_PATH"/ca.cer ] && CERT_PATH=$CERT_PATH/ca.cer
  [ -z "$domain" ] && domain=${CERT_PATH%/*} && domain=${domain##*/} && domain=${domain%.cer} && domain=${domain%.cert} && domain=${domain%.csr} && domain=${domain%.key}
  CERT_PATH=/etc/acme/$domain/$domain.cer
  [ -z "$CA_CERT_PATH" ] && CA_CERT_PATH=/etc/acme/$domain/ca.cer
  [ -z "$CERT_FULLCHAIN_PATH" ] && CERT_FULLCHAIN_PATH=/etc/acme/$domain/fullchain.cer
  [ -z "$CERT_KEY_PATH" ] && CERT_KEY_PATH=/etc/acme/$domain/$domain.key
  [ -z "$config_home" ] && config_home=${CERT_PATH%/*} && config_home=${config_home%/*}
  safe_domain=${CERT_PATH%/*}
  safe_domain=${safe_domain##*/}
  safe_domain=${safe_domain//\*/wildcard}
fi

[ -z "$config_home" ] && echo "Error: config_home not defined" && exit 1
[ ! -d "$config_home" ] && echo "Error: Cannot find config_home directory ($config_home)" && exit 1
#echo domain=$domain
#echo safe_domain=$safe_domain
#echo config_home=$config_home
#[ -n "$RENEWED_LINEAGE" ] && echo RENEWED_LINEAGE=$RENEWED_LINEAGE
#echo CERT_PATH=$CERT_PATH
#echo CA_CERT_PATH=$CA_CERT_PATH
#echo CERT_FULLCHAIN_PATH=$CERT_FULLCHAIN_PATH
#echo CERT_KEY_PATH=$CERT_KEY_PATH

# Acme variables:
# Acme names wildcard domains as "*.domainname"
# $CA_CERT_PATH=/etc/acme/DOMAINNAME/ca.cer
# $CERT_FULLCHAIN_PATH=/etc/acme/DOMAINNAME/fullchain.cer
# $CERT_KEY_PATH=/etc/acme/DOMAINNAME/host.example.com.key
# $CERT_PATH=/etc/acme/DOMAINNAME/host.example.com.cer
# $CERT_PFX_PATH=/etc/acme/DOMAINNAME/host.example.com.pfx
# $Le_Domain

# Define variables for acme.sh

# Define some variables
inifile=$config_home/domains.ini

# Example $config_home/domains.ini
#[example.com]
#services=nginx,smtpd
#docker=homeassistant,plex
#plex_domain=plex.example.com
#docker_compose_yaml=/path/to/docker-compose.yml
#
#[fkb.example.com]
#fully_kiosk_browser=1
#cmdfile=/root/.fkburl
#webdir=/var/www/html
#weburl=http://192.168.0.1

## services is a comma separated list of systemd services to be restarted
## docker is a comma separated list of docker containers to be restarted

## For Fully Kiosk Browser:
## The script /srv/scripts/sbin/gen_fully_cert script must exist
## cmdfile is a file that contains the REST command url for FKB like
##   fullykioskcommand="https://fkb.example.com:2323/?password=fkbpassword&type=json"
## webdir is a path on the system running this script to copy the FKB cert zip file to
## weburl is the URL to the web server on the system running this script from where FKB
## can download the cert zip file

# Default to /etc/ssl; use /etc/pki/tls for Non-Debian/Arch (Red Hat)
progname=${0##*/}
progname=${progname%.sh}
ssldir=/etc/ssl
[ -f /etc/os-release ] && . /etc/os-release
[ "$ID" != debian -a "$ID_LIKE" != debian -a "$ID" != arch -a "$ID_LIKE" != arch ] && ssldir=/etc/pki/tls

# Define print_log function
print_log() { date +"%b %e %H:%M:%S $hostname $progname[$$]: $*"; }

libpath="${0%/*}"/../lib:$HOME/src/scripts/lib:/srv/scripts/lib
PATH="$libpath" . _config 2> /dev/null || { echo "Error: Cannot load _config library" >&2; exit 1; }

# Read Domain Settings
if [ -r $inifile ]; then
  services_list=$(get_config_value "$inifile" "$safe_domain" services)
  docker_list=$(get_config_value "$inifile" "$safe_domain" docker)
  plex_domain=$(get_config_value "$inifile" "$safe_domain" plex_domain)
  fully_kiosk_browser=$(get_config_value "$inifile" "$safe_domain" fully_kiosk_browser)
  splunkdir=$(get_config_value "$inifile" "$safe_domain" splunkdir)
  postgresuser=$(get_config_value "$inifile" "$safe_domain" postgresuser)
  postgresdir=$(get_config_value "$inifile" "$safe_domain" postgresdir)
  webdir=$(get_config_value "$inifile" "$safe_domain" webdir)
  weburl=$(get_config_value "$inifile" "$safe_domain" weburl)
  cmdfile=$(get_config_value "$inifile" "$safe_domain" cmdfile)
  docker_compose_yaml=$(get_config_value "$inifile" "$safe_domain" docker_compose_yaml)
  mikrotik_router=$(get_config_value "$inifile" "$safe_domain" mikrotik_router)
  mikrotik_user=$(get_config_value "$inifile" "$safe_domain" mikrotik_user)
  mikrotik_key=$(get_config_value "$inifile" "$safe_domain" mikrotik_key)
fi

print_log "Copying cert files to $ssldir"
cp $CERT_PATH $ssldir/certs/$safe_domain.crt
cp $CA_CERT_PATH $ssldir/certs/${safe_domain}_ca.crt
cp $CERT_FULLCHAIN_PATH $ssldir/certs/${safe_domain}_bundle.pem
chmod 644 $ssldir/certs/{$safe_domain.crt,${safe_domain}_ca.crt,${safe_domain}_bundle.pem}
chown root $ssldir/certs/{$safe_domain.crt,${safe_domain}_ca.crt,${safe_domain}_bundle.pem}

# If the private key doesn't exist or it has changed, copy the private key
if [ ! -r $ssldir/private/$safe_domain.key ] || \
    ! cmp $CERT_KEY_PATH $ssldir/private/$safe_domain.key > /dev/null 2>&1; then
  cp $CERT_KEY_PATH $ssldir/private/$safe_domain.key
  chmod 600 $ssldir/private/$safe_domain.key
  chown root:root $ssldir/private/$safe_domain.key
fi
touch $ssldir/private/${safe_domain}_archive.pem
chmod 600 $ssldir/private/${safe_domain}_archive.pem
chown root:root $ssldir/private/${safe_domain}_archive.pem
cat $CERT_KEY_PATH > $ssldir/private/${safe_domain}_archive.pem
cat $CERT_FULLCHAIN_PATH >> $ssldir/private/${safe_domain}_archive.pem
touch -r $CERT_FULLCHAIN_PATH $ssldir/private/${safe_domain}_archive.pem

# If plex_domain is defined in the ini file, when that cert is renewed, generate the Plex pfx file
if [ -n "$plex_domain" ]; then
  print_log "Updating Plex pfx file"
  openssl pkcs12 -export \
    -in $CERT_FULLCHAIN_PATH -inkey $CERT_KEY_PATH \
    -out $ssldir/private/${safe_domain}_archive.pfx -name "$plex_domain" -password pass:PlexSSLPass \
    -certpbe AES-256-CBC -keypbe AES-256-CBC -macalg SHA256
    # As of Plex 1.32.0.6918 including a switch to OpenSSLv3, less secure encryption methods were dropped
    # https://forums.plex.tv/t/pms-ssl-uses-plex-direct-lets-encrypt-ssl-certificate-instead-of-custom-configured-certificate/837747
fi

[ -n "$debug" ] && print_log fully_kiosk_browser=$fully_kiosk_browser
[ -n "$debug" ] && print_log weburl=$weburl
[ -n "$debug" ] && print_log webdir=$webdir
[ -n "$debug" ] && print_log cmdfile=$cmdfile

# If fully_kiosk_browser is defined in the ini file, generate the zip file FKB wants
if [ -n "$fully_kiosk_browser" -a -n "$weburl" -a -n "$webdir" -a -n "$cmdfile" -a -r "$cmdfile" -a -x /srv/scripts/sbin/gen_fully_cert ]; then
  print_log "Updating Fully Kiosk Browser Cert"
  . $cmdfile

  [ -n "$debug" ] && print_log fullykioskcommand=$fullykioskcommand

  if which zip > /dev/null 2>&1 && [ -n "$fullykioskcommand" ]; then
    print_log "Updating Fully Kiosk Browser Cert"

    /srv/scripts/sbin/gen_fully_cert $CERT_KEY_PATH $CERT_PATH $safe_domain
    #openssl pkcs12 -export -out $ssldir/private/${domain%%.*}_fully-remote-admin-ca.p12 \
    #  -inkey $CERT_KEY_PATH -in $CERT_PATH -passout pass:fully

    print_log "Uploading Fully Kiosk Browser SSL cert file and restarting FKB for $safe_domain"
    tmpdir=$(mktemp -d $webdir/tmpdir.XXXXXXXXXXXXXXXXXX)
    ## use zip file
    cp $ssldir/private/$safe_domain.p12.zip $tmpdir
    chmod -R o+rX $tmpdir
    curl -k "$fullykioskcommand&cmd=deleteFile&filename=/storage/emulated/0/Android/data/de.ozerov.fully/fully-remote-admin-ca.p12"
    sleep 2
    # curl -k "$fullykioskcommand&cmd=loadZipFile&url=$weburl/${tmpdir##*/}/$safe_domain.p12.zip&dir=/storage/emulated/0/Android/data/de.ozerov.fully"
    curl -k "$fullykioskcommand&cmd=loadZipFile&url=$weburl/${tmpdir##*/}/$safe_domain.p12.zip&dir=/storage/emulated/0"
    sleep 2
    curl -k "$fullykioskcommand&cmd=restartApp"
    rm -Rf $tmpdir
  else
    print_log "Could not update Fully Kiosk Browser Cert for $safe_domain (missing zip command) or fullykioskcommand not defined in $cmdfile"
  fi
fi

# Restart systemd services
if [ -n "$services_list" ]; then
  if [[ ,$services_list, = *,splunk,* ]]; then
    if [ -n "$splunkdir" ]; then
      mkdir -p $splunkdir/etc/auth/letsencrypt
      touch $splunkdir/etc/auth/letsencrypt/server.pem
      chmod 600 $splunkdir/etc/auth/letsencrypt/server.pem
      cat $CERT_PATH $CERT_KEY_PATH $CA_CERT_PATH > $splunkdir/etc/auth/letsencrypt/server.pem
      chown -R splunk:splunk $splunkdir/etc/auth/letsencrypt
    else
      echo "Error: \$splunkdir not defined"
    fi
  fi
  print_log "Restarting services: $services_list"
  systemctl restart $(echo $services_list | sed -r 's/,/ /g;s/\.service//g;s/( |$)/.service /g')
fi

print_log "domain=$safe_domain"
print_log "inifile=$inifile"
print_log "docker_list=$docker_list"
docker_compose_yaml=${docker_compose_yaml:=/srv/containers/$hostname/docker-compose.yaml}
if [ -n "$docker_list" ] && docker compose --help > /dev/null 2>&1 && [ -r $docker_compose_yaml ]; then
  if [[ ,$docker_list, = *,postgres,* ]]; then
    if [ -n "$postgresdir" ] && [ -n "$postgresuser" ]; then
      cp $CA_CERT_PATH $postgresdir
      touch $postgresdir/server.key
      cp $CERT_PATH $postgresdir/server.crt
      cp $CERT_KEY_PATH $postgresdir/server.key
      chmod 600  $postgresdir/server.key
      chown $postgresuser $postgresdir/server.key $postgresdir/server.crt $postgresdir/ca.crt
    else
      echo "Error: \$postgresdir or \$postgresuser not defined"
    fi
  fi
  print_log "Restarting containers: $docker_list"
  docker compose -f $docker_compose_yaml restart $(echo $docker_list | sed 's/,/ /g')
fi

if [ -n "$mikrotik_router" ]; then
  if [ -z "$mikrotik_user" ] && [ -n "$SUDO_USER" ]; then
    mikrotik_user=$SUDO_USER
  fi
  if [ -z "$mikrotik_user" ]; then
    mikrotik_user=$LOGNAME
  fi
  if [ -z "$mikrotik_key" ]; then
    echo "Error: mikrotik_key must be defined"
    exit 1
  fi
  if [ -n "$mikrotik_key" ] && [ ! -r $mikrotik_key ]; then
    echo "Error: Cannot read $mikrotik_key"
    exit 1
  fi
  set -o xtrace
  scp -i $mikrotik_key $CERT_PATH $mikrotik_user@$mikrotik_router:;
  scp -i $mikrotik_key $CERT_KEY_PATH $mikrotik_user@$mikrotik_router:;
  scp -i $mikrotik_key $CA_CERT_PATH $mikrotik_user@$mikrotik_router:;
  ssh -i $mikrotik_key $mikrotik_user@$mikrotik_router "/certificate import file-name=\"${CERT_PATH##*/}\" name=\"$domain\""
  ssh -i $mikrotik_key $mikrotik_user@$mikrotik_router "/certificate import file-name=\"${CERT_KEY_PATH##*/}\" name=\"$domain\""
  ssh -i $mikrotik_key $mikrotik_user@$mikrotik_router "/certificate import file-name=\"${CA_CERT_PATH##*/}\" name=\"$domain\""
  set +o xtrace
fi
