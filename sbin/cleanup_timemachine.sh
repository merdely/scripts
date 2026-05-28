#!/usr/bin/env bash

progname=${0##*/}
progname=${progname%.sh}
print_only=false
while getopts ":hp" opt; do
  case $opt in
    p)
      print_only=true
      ;;
    *)
      echo "usage: $progname [-h] [-p] [DIR1..DIRn]"
      echo "           -h    : this help text"
      echo "           -p    : print_only"
      echo "           DIRn  : directories that contain YYYY-mm-dd_HH-MM-SS directories to clean"
      exit
      ;;
  esac
done
shift $((OPTIND -1))

! $print_only && [ $(id -u) != 0 ] && echo "Error: The program must be run as root" && exit 1

backups=/ext/Backups
list=$(find $backups -mindepth 1 -maxdepth 1 -type d | sort)

[ -n "$1" ] && list="$@"

for dir in $list; do
  [ ! -d "$dir" ] && continue
  count=$(ls "$dir" | grep -c [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9])
  [ $count -lt 2 ] && continue
  for datedir in "$dir"/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9]; do
    [ ! -d "$datedir" ] && continue
    if [[ ! "${datedir##*/}" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2} ]]; then
      echo "Warning: $datedir is not a valid date format - skipping"
      continue
    fi
    datestr=$(echo "${datedir##*/}" | sed -r 's/^([0-9]{4}-[0-9]{2}-[0-9]{2})_([0-9]{2})-([0-9]{2})-([0-9]{2})$/\1T\2:\3:\4/')
    date=$(date -d $datestr)
    dom=$(date -d $datestr +%d)
    epoch=$(date -d $datestr +%s)
    sevendays=$(date -d '7 days ago' +%s)
    if [ $dom != 01 ] && [ $dom != 15 ] && [ $epoch -lt $sevendays ]; then
      echo Delete backup $datedir
      ! $print_only && rm -Rf $datedir
    #  true
    #else
    #  #echo NOT DELETING $datedir
    #  true
    fi
  done
done
