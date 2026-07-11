#!/usr/bin/env bash

progname=${0##*/}
progname=${progname%.sh}
inifile=$HOME/.config/tasmotarc

usage() {
  echo "usage: $progname [Options]"
  echo "Options:"
  echo "  -h         : print this help text"
  echo "  -b         : perform backup (default mode)"
  echo "  -g         : create html page with devices and links"
  echo "  -l         : list tasmota devices"
  echo "  -L         : list tasmota devices with: name,ip,template,is-out-of-date,version"
  echo "  -i INIFILE : path to tasmota config file (ini format)"
  echo "Example INIFILE:"
  echo "    [tasmota]"
  echo "    ha_token: TOKENHERE"
  echo "    entity: sensor.tasmota_devices_list"
  echo "    tasmota_pass: TASMOTADEVICEPASSWORD"
  echo "    backup_dir: /path/to/tasmota/backups"
  exit
}

mode=backup
while getopts ":hblLgi:" opt; do
  case $opt in
    b) mode=backup ;;
    g) mode=html ;;
    l) mode=list ;;
    L) mode=listextended ;;
    i)
       if [ -r "$OPTARG" ]; then
         inifile=$OPTARG
       else
         echo "Error: Cannot read INIFILE ($OPTARG)" >&2
         exit 1
       fi
       ;;
    *) usage ;;
  esac
done
shift $((OPTIND -1))

libpath="${0%/*}"/../lib:$HOME/src/scripts/lib:/srv/scripts/lib
PATH="$libpath" . _config 2> /dev/null || { echo "Error: Cannot load _config library" >&2; exit 1; }

if [ -r "$inifile" ]; then
  ha_token=$(get_config_value "$inifile" tasmota ha_token)
  entity=$(get_config_value "$inifile" tasmota entity)
  tasmota_pass=$(get_config_value "$inifile" tasmota tasmota_pass)
  backup_dir=$(get_config_value "$inifile" tasmota backup_dir)
  ha_url=$(get_config_value "$inifile" tasmota ha_url)
  dns_domain=$(get_config_value "$inifile" tasmota dns_domain)
else
  echo "Error: Cound not find $inifile"
  exit 1
fi

[ -z "$ha_token" ] && echo "Error: 'ha_token' not found in $inifile" && exit 1
[ -z "$entity" ] && echo "Error: 'entity' not found in $inifile" && exit 1
[ -z "$tasmota_pass" ] && echo "Error: 'tasmota_pass' not found in $inifile" && exit 1
[ -z "$backup_dir" ] && echo "Error: 'backup_dir' not found in $inifile" && exit 1
[ -z "$ha_url" ] && echo "Error: 'ha_url' not found in $inifile" && exit 1

backups=$backup_dir/backups

dig_found=false
device_specified=false
[ -n "$1" ] && device_specified=true
device_list=()
while [ -n "$1" ]; do
  if [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    device_list+=("$1")
  else
    if ! $dig_found; then
      if which dig &> /dev/null; then
        dig_found=true
      else
        echo "Error: dig command not found" >&2
        exit 1
      fi
    fi
    h=$1
    t=${h%%.*}
    [ -n "$dns_domain" ] && [ "$t" = "$h" ] && h=$h.$dns_domain
    i=$(dig +short "$h")
    if [[ $i =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      device_list+=("$i")
    else
      h=tasmota-$h
      i=$(dig +short "$h")
      if [[ $i =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        device_list+=("$i")
      else
        echo "Warning: Could not find IP for $1" >&2
      fi
    fi
  fi
  shift
done

if $device_specified; then
  tasmota_devices="${device_list[*]}"
  tasmota_devices="${tasmota_devices// /|}"
else
  tasmota_devices=$(curl -sL -H "Authorization: Bearer $ha_token" "$ha_url/api/states/$entity" | \
    jq -r '.attributes.devices')

  if [ "$tasmota_devices" = "" ]; then
    curl -sLH "Authorization: Bearer $ha_token" \
      -d "{\"entity_id\": \"$entity\"}" \
      "$ha_url/api/services/homeassistant/update_entity" > /dev/null 2>&1
    sleep 2
    tasmota_devices=$(curl -sL -H "Authorization: Bearer $ha_token" | \
      "$ha_url/api/states/$entity" | jq -r '.attributes.devices')
  fi

  if [ "$tasmota_devices" = "" ]; then
    echo "Error: Could not determine Tasmota Devices"
    exit 1
  fi
fi

tasmota_version=$(curl -s https://api.github.com/repos/arendst/Tasmota/releases/latest | jq -r .tag_name)

OIFS=$IFS
IFS="|"

names=()
ips=()
versions=()
templates=()
failures=()
ood=()
total=0
done=0
long=0
for device in $tasmota_devices; do
  total=$((total+1))
  name=$(echo "$device"|cut -d, -f1)
  ip=$(echo "$device"|cut -d, -f2)
  ip=${ip% }

  status_json=$(curl -sLu admin:"$tasmota_pass" "http://$ip/cm?cmnd=STATUS%200")
  if [[ -z "$status_json" ]] || ! jq -n --argjson j "$status_json" '$j' &> /dev/null; then
    echo "Error: Could not get Status Info for $name via http" && failures+=("$name") && continue
  fi

  out=$(jq -rn --argjson j "$status_json" '$j.Status.DeviceName' 2> /dev/null)
  [ -n "$out" ] && [ "$out" != null ] && name=$out

  # Get Template
  out=$(curl -sLu admin:"$tasmota_pass" "http://$ip/cm?cmnd=Template" 2>&1 | jq -r '.NAME' 2> /dev/null)
  [ -n "$out" ] && [ "$out" != null ] && template=$out


  dirname=${name// /_}
  [ ${#name} -gt "$long" ] && long=${#name}
  [ "$ip" = unavailable ] && failures+=("$name") && continue

  # Get Firmware Version
  version=$(jq -rn --argjson j "$status_json" '$j.StatusFWR.Version' | sed 's/(/_/;s/)//')

  [ "v${version%_release*}" != "$tasmota_version" ] && ood+=("$name")
  names+=("$name")
  ips+=("$ip")
  versions+=("$version")
  templates+=("$template")
  [[ "$mode" == html ]] && continue

  if [[ "$mode" == backup ]]; then
    # Get MAC Address
    out=$(curl -sLu admin:"$tasmota_pass" "http://$ip/cm?cmnd=STATUS%205")
    ! echo "$out" | grep -q "StatusNET" && echo "Error: Could not get StatusNET for $name via http" && failures+=("$name") && continue
    mac=$(jq -rn --argjson j "$status_json" '$j.StatusNET.Mac' 2> /dev/null | tr -d :)

    filename=$(date "+$mac-%F_%H_%M_%S_$version.dmp")
    mkdir -p "$backups/$dirname"
    decode-config -w --source http://"$ip" --password "$tasmota_pass" --backup-file "$backups/$dirname/$filename"
    if [ -r "$backups/$dirname/$filename" ]; then
      done=$((done+1))
      rm -f "$backups/$dirname/latest.dmp"
      ln -s "$backups/$dirname/$filename" "$backups/$dirname/latest.dmp"
    else
      failures+=("$name")
    fi
  fi
done
IFS=$OIFS

if [[ "$mode" == backup ]]; then
  echo
  echo SUMMARY:
  echo --------
  echo Backed up $done of $total Tasmota devices
  for i in $(seq 0 $((${#names[@]}-1))); do
    printf "  - %-${long}s : %s\n" "${names[$i]}" "${versions[$i]}"
  done
  if [ ${#failures[@]} -gt 0 ]; then
    echo
    OIFS=$IFS
    IFS=,
    echo "ERROR: Backups for these devices failed: ${failures[*]}" 
    IFS=$OIFS
  fi
else
  if [[ "$mode" == html ]]; then
    cat <<-EOF
    <html>
    <head>
    <title>Tasmota Device List</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      body {
        font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
        background: #f9fafb;
        color: #333;
        margin: 0;
        padding: 2rem;
        display: flex;
        flex-direction: column;
        align-items: center;
      }
      h1 {
        font-size: 2.2rem;
        margin-bottom: 0.5rem;
        color: #111;
        text-align: center;
      }
      h3 {
        font-weight: normal;
        color: #555;
        margin-bottom: 1.5rem;
        text-align: center;
      }
      ul {
        list-style: none;    /* remove bullets */
        padding: 0;
        margin: 0 auto;      /* center horizontally */
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1rem;
        width: 100%;
        max-width: 1200px;   /* container width limit */
      }
      li {
        background: white;
        padding: 0.75rem 1rem;
        border-radius: 0.75rem;
        box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        transition: transform 0.15s ease, box-shadow 0.15s ease;
        text-align: center;
      }
      li:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
      }
    </style>
    </head>
    <body>
    <h1>Tasmota Device List</h1>
    <h3>${#names[@]} Devices</h3>
    <ul>
EOF
  fi
  one_printed=false
  for i in $(seq 0 $((${#names[@]}-1))); do
    if [[ "$mode" == html ]]; then
      printf "  <li><a href='http://%s/'>%-${long}s</a>\n" "${ips[$i]}" "${names[$i]}"
    elif [[ "$mode" == listextended ]]; then
      is_ood=false
      [ "v${versions[$i]%_release*}" != "$tasmota_version" ] && is_ood=true
      echo "${names[$i]},${ips[$i]},${templates[$i]},$is_ood,v${versions[$i]%_release*}"
    else
      if ! $one_printed; then
        echo "Tasmota Devices (${#names[@]}):"
        one_printed=true
      fi
      v=${versions[$i]}
      v=v${v%_release*}
      unset vtag
      [ "$v" != "$tasmota_version" ] && vtag=" (Out of date)"
      printf "  - %-${long}s : %s%s\n" "${names[$i]}" "${versions[$i]}" "$vtag"
    fi
  done
  if [[ "$mode" == html ]]; then
    echo "</ul>"
  fi
  if [ ${#failures[@]} -gt 0 ]; then
    OIFS=$IFS
    IFS=,
    if [[ "$mode" == html ]]; then
      echo "<p>Could not connect to: ${failures[*]}</p>"
    else
      echo "Could not connect to: ${failures[*]}" >&2
    fi
    IFS=$OIFS
  fi
  if [[ "$mode" == html ]]; then
    echo "<p>Previous <a href='list.php'>Device List Pages</p>"
    echo "</body>"
    echo "</html>"
  fi
fi

if [[ "$mode" != listextended ]]; then
  echo "Most recent Tasmota release: $tasmota_version"
  if [ ${#ood[@]} -gt 0 ]; then
    OIFS=$IFS
    IFS=,
    list="${ood[*]}"
    IFS=$OIFS
    list="${list//,/, }"
    if [[ "$mode" == html ]]; then
      echo "<p>Most recent Tasmota release: $tasmota_version<br />"
      echo "Device that need updates: $list</p>"
    else
      echo "Device that need updates: $list" >&2
    fi
  fi
fi

