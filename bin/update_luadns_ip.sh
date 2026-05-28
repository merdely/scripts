#!/usr/bin/env bash

# Determine public IP address using one of three web sites (checkip.dyndns.org, ip.me, or ifconfig.co)
# If the public IP address is different than the IP address in DNS for the configured hostname, update
# it in LUADNS

! which which > /dev/null 2>&1 && alias which='command -v'

unset insecure
insecure="-k"

unset debug
force_update=false
config=$HOME/.config/luadnsrc
host=default
public=true

usage() {
  echo "usage: ${0##*/} [-h] [-d] [-f] [-c configfile] [-H hostname] [-p]"
  echo "           -d            : show debug info"
  echo "           -f            : force update even if IP has not changed"
  echo "           -c configfile : specify config file (default: $config)"
  echo "           -H hostname   : specify a hostname/section in config file (default: 'default')"
  echo "           -p            : use private IP address instead of public"
  exit
}

while getopts ":hdfc:H:p" opt; do
  case $opt in
    d)
      debug=true
      ;;
    c)
      config=$2
      ;;
    H)
      host=$2
      ;;
    f)
      force_update=true
      ;;
    p)
      public=false
      ;;
    h|\?) usage
      ;;
  esac
done
shift $((OPTIND -1))

which awk > /dev/null 2>&1 || { echo "Error: awk command is required"; exit; }
which curl > /dev/null 2>&1 || { echo "Error: curl command is required"; exit; }
which dig > /dev/null 2>&1 || { echo "Error: dig command is required"; exit; }
which jq > /dev/null 2>&1 || { echo "Error: jq command is required"; exit; }

print_json() {
  # $1: public ip
  # $2: dns record
  # $3: dynamic hostname
  # $4: status
  # $5: updated_at
  echo "{"
  echo "  \"public_ip\": \"$1\","
  echo "  \"dns_record\": \"$2\","
  echo "  \"dynamic_hostname\": \"$3\","
  echo "  \"status\": \"$4\","
  echo "  \"updated_at\": \"$5\""
  echo "}"
}

libpath="${0%/*}"/../lib:$HOME/src/scripts/lib:/srv/scripts/lib
PATH="$libpath" . _config 2> /dev/null || { echo "Error: Cannot load _config library" >&2; exit 1; }

# Config File Format
# [hostname]
# domain_name=DNS Domain Name
# host_name=DNS host record (if section name is "default" a host_name must be specified)
# user_name=LUADNS Email Address
# api_key=LUADNS API Key

# Read Domain Settings
if [ -r $config ]; then
  domain_name=$(get_config_value "$config" "$host" domain_name)
  host_name=$(get_config_value "$config" "$host" host_name)
  user_name=$(get_config_value "$config" "$host" user_name)
  api_key=$(get_config_value "$config" "$host" api_key)
else
  echo "Error: Could not read config file '$config'"
  exit 1
fi

[ -z "$host_name" ] && [ $host = default ] && echo "Error: Must specify host_name in $config" && exit 1
[ -z "$host_name" ] && host_name=$host

[ -z "$domain_name" ] && echo "Error: Must specify domain_name in $config" && exit
[ -z "$user_name" ] && echo "Error: Must specify user_name in $config" && exit
[ -z "$api_key" ] && echo "Error: Must specify api_key in $config" && exit

$debug && echo domain_name = $domain_name
$debug && echo host_name = $host_name
$debug && echo user_name = $user_name
$debug && echo api_key = $api_key

dynamic_name=$host_name.$domain_name

if $public; then
  # Determine newip
  newip=$(curl -s $insecure http://checkip.dyndns.org | sed -r 's/.*: ([0-9]{1,3}(\.[0-9]{1,3}){3}).*$/\1/')
  # Verify newip is valid (no errors from the curl command)
  if ! [[ $newip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
    newip=$(curl -s $insecure http://ip.me)
    if ! [[ $newip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
      newip=$(curl -s $insecure http://ifconfig.co)
      if ! [[ $newip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
        newip="Error with checkip.dyndns.org"
      fi
    fi
  fi
else
  int=$(ip -4 route list default | awk '{print $5}')
  newip=$(ip -4 addr list dev $int | awk '/inet/{print substr($2,1,index($2,"/")-1)}')
fi

# Determine current DNS IP
dnsip=$(dig +short $dynamic_name 2> /dev/null)
# Verify dnsip is valid (no errors from the dig command)
if ! [[ $dnsip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
  dnsip="Error getting IP for $dynamic_name"
fi

if [[ $newip =~ ^Error ]] || [[ $dnsip =~ ^Error ]]; then
  print_json "$newip" "$dnsip" "$dynamic_name" "Error" "Unavailable"
  exit
fi

# Be silent unless -d/debug
unset silent
! $debug && silent=-s

# Get Zone Number for domain
$debug && echo "Determining Zone Number for $domain_name"
$debug && echo curl $silent $insecure -f -u "$user_name:$api_key" -H 'Accept: application/json' https://api.luadns.com/v1/zones \| \
           jq '.[] \| select(.name=="'"$domain_name"'").id'
zone_num=$(curl $silent $insecure -f -u "$user_name:$api_key" -H 'Accept: application/json' https://api.luadns.com/v1/zones | \
           jq '.[] | select(.name=="'"$domain_name"'").id')
[ -z "$zone_num" ] && echo "Error: Could not determine the Zone ID for $domain_name" && exit 1
$debug && echo "Zone number: $zone_num"

# If the IPs are different OR force is specified
if [[ $newip != $dnsip ]] || $force_update; then
  # Get Record number for host
  $debug && echo "Determining Record Number and TTL for $dynamic_name"
  $debug && echo curl $silent $insecure -f -u "$user_name:$api_key" -H 'Accept: application/json' \
             https://api.luadns.com/v1/zones/$zone_num/records \| \
             jq -r '.[] | select(.name=="'"$dynamic_name"'." and .type=="A")|.id,.ttl'
  read -d "\n" record_num ttl <<< $(curl $silent $insecure -f -u "$user_name:$api_key" -H 'Accept: application/json' \
             https://api.luadns.com/v1/zones/$zone_num/records | \
             jq -r '.[] | select(.name=="'"$dynamic_name"'." and .type=="A")|.id,.ttl')
  [ -z "$record_num" -o -z "$ttl" ] && echo "Error: Could not determine the Record ID or TTL for $dynamic_name" && exit 1

  # Update IP address
  $debug && echo "Updating IP address for $dynamic_name"
  $debug && echo curl $silent $insecure -f -u "$user_name:$api_key" -X PUT \
    -d '{"name": "'"$dynamic_name."'", "type": "A", "ttl": '"$ttl"', "content": "'"$newip"'"}' \
    -H 'Accept: application/json' https://api.luadns.com/v1/zones/$zone_num/records/$record_num
  output=$(curl $silent $insecure -f -u "$user_name:$api_key" -X PUT \
    -d '{"name": "'"$dynamic_name."'", "type": "A", "ttl": '"$ttl"', "content": "'"$newip"'"}' \
    -H 'Accept: application/json' https://api.luadns.com/v1/zones/$zone_num/records/$record_num)
  err=$?
  [ $err != 0 ] && echo "Error: Could not update IP address for $dynamic_name ($err)" && echo $output && exit 1
  $debug && echo "$output"
fi

# Get the time the IP was last updated
updated_at=$(curl $silent $insecure -f -u "$user_name:$api_key" -H 'Accept: application/json' \
             https://api.luadns.com/v1/zones/$zone_num/records | \
             jq -r '.[] | select(.name=="'"$dynamic_name"'." and .type=="A").updated_at')

print_json $newip $dnsip $dynamic_name "Up to date" $updated_at

