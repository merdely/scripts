#!/usr/bin/env bash

#                                  day  day  day  mo    mo
# Listed in order of their limits: 300, 200, 100, 1000, 500
services=("brevo" "mailjet" "mailgun" "smtp2go" "mailersend")

config_file=$HOME/.config/smtprc
luadns_file=$HOME/.config/luadnsrc

smtpconf=/srv/docker/smtpd/smtpd.conf

! which which > /dev/null 2>&1 && alias which='command -v'
! which curl > /dev/null 2>&1 && echo "Error: Cannot find curl command" >&2 && exit 1
! which jq > /dev/null 2>&1 && echo "Error: Cannot find jq command" >&2 && exit 1
! which bc > /dev/null 2>&1 && echo "Error: Cannot find bc command" >&2 && exit 1
! which awk > /dev/null 2>&1 && echo "Error: Cannot find awk command" >&2 && exit 1
! which sed > /dev/null 2>&1 && echo "Error: Cannot find sed command" >&2 && exit 1

declare -A apikeys
declare -A secretkeys
declare -A limits
declare -A default_limits

progname=${0##*/}
progname=${progname%.sh}
dnsmode=false
smtpmode=false
listmode=false
printmode=false
testmode=false
verbose=false
while getopts ":DSlptv" opt; do
  case $opt in
    D)
      dnsmode=true
      ;;
    S)
      smtpmode=true
      [ ! -f $smtpconf ] && echo "Error: Cannot find smtpd.conf for smtp container" >&2 && exit 1
      ;;
    l)
      listmode=true
      ;;
    p)
      printmode=true
      ;;
    t)
      testmode=true
      ;;
    v)
      verbose=true
      ;;
    *)
      echo "usage: $progname [-D|-S|-l|-p|-t] [-v]"
      echo "         -S     : Update smtpd.conf for smtpd docker container"
      echo "         -D     : DNS mode - Update DNS record"
      echo "         -l     : List mode (default)"
      echo "         -p     : Print mode"
      echo "         -t     : Test mode"
      echo "         -v     : Be verbose"
      exit
      ;;
  esac
done
shift $((OPTIND -1))

if [ $((dnsmode + smtpmode + listmode + printmode + testmode)) = 0 ]; then
  printmode=true
elif [ $((dnsmode + smtpmode + listmode + printmode + testmode)) -gt 1 ]; then
  echo "Error: Only one of -D, -S, -l, -p, -t can be given" >&2
  exit 1
fi

get_usage() {
  local count=0
  local ret=0
  case "$1" in
    ""|brevo)
      service=brevo
      datestr=$(date +%F)
      curl_out=$(curl --fail --location --silent --request GET \
           --header 'accept: application/json' \
           --header "api-key: ${apikeys[$service]}" \
           --header 'content-type: application/json' \
           "https://api.brevo.com/v3/smtp/statistics/reports?limit=10&offset=0&sort=desc&startDate=$datestr&endDate=$datestr")
      ret=$?
      count=$(echo $curl_out | jq -r '.reports[] | .delivered')
      ;;
    mailgun)
      startdate=$(date "+%a, %d %b %Y 00:00:00 %z")
      enddate=$(date "+%a, %d %b %Y 23:59:59 %z")
      curl_out=$(curl --fail --location --silent -X POST \
           -u "${apikeys[$1]}:${secretkeys[$1]}" \
           -H 'Content-Type: application/json' \
           -d "{ \"resolution\": \"day\", \"start\": \"$startdate\", \"end\": \"$enddate\", \"metrics\": [ \"sent_count\" ] }" \
           https://api.mailgun.net/v1/analytics/metrics)
      ret=$?
      count=$(echo $curl_out | jq -r '.items[] | .metrics.sent_count')
      ;;
    mailjet)
      datestr=$(date +%FT00:00:00)
      curl_out=$(curl --fail --location --silent -X GET \
           --user "${apikeys[$1]}:${secretkeys[$1]}" \
           "https://api.mailjet.com/v3/REST/statcounters?CounterSource=APIKey&CounterTiming=Message&CounterResolution=Day&FromTS=$datestr")
      ret=$?
      count=$(echo $curl_out | jq -r '.Data[] | .MessageSentCount')
      ;;
    smtp2go)
      curl_out=$(curl --fail --location --silent --request POST \
           --url https://api.smtp2go.com/v3/stats/email_cycle \
           --header 'Content-Type: application/json' \
           --header "X-Smtp2go-Api-Key: ${apikeys[$1]}" \
           --header 'accept: application/json')
      ret=$?
      count=$(echo $curl_out | jq -r '.data.cycle_used')
      ;;
    mailersend)
      curl_out=$(curl --fail --location --silent -X GET \
               -H 'Content-Type: application/json' \
               -H 'X-Requested-With: XMLHttpRequest' \
               -H "Authorization: Bearer ${apikeys[$1]}" \
               "https://api.mailersend.com/v1/api-quota")
      ret=$?
      remaining=$(echo $curl_out | jq -r '.remaining')
      count=$((${limits[$1]} - $remaining))
      ;;
    *)
      echo "Error: $1 is an invalid service" >&2
      ;;
  esac
  if [ $ret != 0 ] || [[ ! $count =~ ^[0-9]+$ ]]; then
    echo "Error: Could not get usage info from ${1^}" >&2
    count=$((${limits[$1]} * 2))
    ret=1
  fi
  echo $count
  return $ret
}

get_limit() {
  local limit=0
  case "$1" in
    ""|brevo|mailgun|mailjet)
      limit=${default_limits[$1]}
      ;;
    smtp2go)
      curl_out=$(curl --fail --location --silent --request POST \
           --url https://api.smtp2go.com/v3/stats/email_cycle \
           --header 'Content-Type: application/json' \
           --header "X-Smtp2go-Api-Key: ${apikeys[$1]}" \
           --header 'accept: application/json')
      [ $? = 0 ] && limit=$(echo $curl_out | jq -r '.data.cycle_max')
      [[ $limit = 0 || ! $limit =~ ^[0-9]+$ ]] && limit=${default_limits[$1]}
      ;;
    mailersend)
      curl_out=$(curl --fail --location --silent -X GET \
               -H 'Content-Type: application/json' \
               -H 'X-Requested-With: XMLHttpRequest' \
               -H "Authorization: Bearer ${apikeys[$1]}" \
               "https://api.mailersend.com/v1/api-quota")
      [ $? = 0 ] && limit=$(echo $curl_out | jq -r '.quota')
      [[ $limit = 0 || ! $limit =~ ^[0-9]+$ ]] && limit=${default_limits[$1]}
      ;;
    *)
      echo "Error: $1 is an invalid service" >&2 && exit 1
      ;;
  esac
  echo $limit
}

[ ! -e $config_file ] && echo "Error: Cannot read $config_file" >&2 && exit 1

libpath="${0%/*}"/../lib:$HOME/src/scripts/lib:/srv/scripts/lib
PATH="$libpath" . _config 2> /dev/null || { echo "Error: Cannot load _config library" >&2; exit 1; }

for service in ${services[@]}; do
  apikeys[$service]=$(get_config_value "$config_file" "$service" api_key)
  limits[$service]=$(get_config_value "$config_file" "$service" limit)
  default_limits[$service]=${limits[$service]}

  # Done read secret keys for brevo or smtp2go
  [ $service != brevo ] && \
    [ $service != smtp2go ] && \
    [ $service != mailersend ] && \
    secretkeys[$service]=$(get_config_value "$config_file" "$service" secret_key)

  # Validate settings
  [ -z "${apikeys[$service]}" ] && echo "Error: Could not read ${service^} api_key from $config_file" >&2 && exit 1
  [ -z "${secretkeys[$service]}" ] && \
    [ $service != brevo ] && \
    [ $service != smtp2go ] && \
    [ $service != mailersend ] && \
    echo "Error: Could not read ${service^} secret_key from $config_file" >&2 && exit 1
  [ -z "${limits[$service]}" ] && echo "Error: Could not read ${service^} limit from $config_file" >&2 && exit 1
  [[ ! ${limits[$service]} =~ ^[0-9]+$ ]] && echo "Error: ${service^} limit (${limits[$service]}) is not a number" >&2 && exit 1
done

if $listmode; then
  echo "Retrieving API information"
  { 
    echo "Service Usage Limit Perc"
    echo "======= ===== ===== ===="
    for service in ${services[@]}; do
      count=$(get_usage $service)
      limits[$service]=$(get_limit $service)
      perc=$(echo "($count * 100) / ${limits[$service]}" | bc)
      [ $perc = 200 ] && perc=XXX && count=XXX
      echo $service $count ${limits[$service]} $perc
    done
  } | column -t
  exit
fi

unset use
for service in ${services[@]}; do
  limits[$service]=$(get_limit $service)
  count=$(get_usage $service)

  percent=$(echo "($count * 100) / ${limits[$service]}" | bc)
  if [ "$percent" -lt 93 ]; then
    use=$service
    break
  fi
  #echo $service: $count ${limits[$service]} $percent%
done

if $printmode; then
  if $verbose; then
    echo "Use $use (used $count of ${limits[$service]})"
  else
    echo $use
  fi
elif $dnsmode; then
  $verbose && echo Updating DNS to use $use
  # Read LUADNS settings
  luadomain=$(get_config_value "$config_file" global dns_domain)
  luarecord=$(get_config_value "$config_file" global dns_record)

  luauser=$(get_config_value "$config_file" "$luadomain" user_name)
  luakey=$(get_config_value "$config_file" "$luadomain" api_key)
  [ -z "$luauser" -o -z "$luakey" ] && echo "Error: Could not read lua settings for $luadomain" >&2 && exit 1

  current_setting=$(dig +short -t TXT $luarecord.$luadomain @ns1.luadns.net | tr -d '"')
  [ $current_setting = $use ] && { $verbose && echo "DNS is already set to $use" >&2; true; } && exit

  zone_num=$(curl -sfu "$luauser:$luakey" -H 'Accept: application/json' https://api.luadns.com/v1/zones \
    | jq '.[] | select(.name=="'"$luadomain"'").id')
  [ -z "$zone_num" ] && echo "Error: Could not determine the Zone ID for $luadomain" >&2 && exit 1
  read -d "\n" record_num ttl <<< $(curl -sfu "$luauser:$luakey" -H 'Accept: application/json' \
    https://api.luadns.com/v1/zones/$zone_num/records | \
    jq -r '.[] | select(.name=="'"$luarecord.$luadomain"'." and .type=="TXT")|.id,.ttl')
  [ -z "$record_num" -o -z "$ttl" ] && echo "Error: Could not determine the Record ID or TTL for $luarecord.$luadomain" >&2 && exit 1

  #echo ====
  #curl -fu "$luauser:$luakey" -X GET \
  #  -H 'Accept: application/json' https://api.luadns.com/v1/zones/$zone_num/records/$record_num
  #echo ====
  #echo curl -fu "$luauser:$luakey" -X PUT \
  #  -d '{"name": "'"$luarecord.$luadomain."'", "type": "TXT", "ttl": '"$ttl"', "content": "'"$use"'"}' \
  #  -H 'Accept: application/json' https://api.luadns.com/v1/zones/$zone_num/records/$record_num
  output=$(curl -fu "$luauser:$luakey" -X PUT \
    -d '{"name": "'"$luarecord.$luadomain."'", "type": "TXT", "ttl": '"$ttl"', "content": "'"$use"'"}' \
    -H 'Accept: application/json' https://api.luadns.com/v1/zones/$zone_num/records/$record_num)
  err=$?
  [ $err != 0 ] && echo "Error: Could not update info for $luarecord.$luadomain ($err)" && echo $output && exit 1
elif $testmode; then
  echo "Use $use (used $count of ${limits[$service]})"
else
  current=$(awk -F' *= *' '$1=="relay_host"{print $2}' $smtpconf)
  if [ $current != "\$$use" ]; then
    $verbose && echo Switching SMTP server to ${use^}
    sed -ri "s/^relay_host *=.*/relay_host = \$$use/" $smtpconf
    docker compose -f /srv/docker/compose.yaml restart smtpd > /dev/null 2>&1
  fi
fi

