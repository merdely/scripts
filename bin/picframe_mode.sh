#!/usr/bin/env bash

if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
  RUN_COMMAND="$SSH_ORIGINAL_COMMAND"
elif [ -n "$1" ]; then
  RUN_COMMAND="$1"
else
  RUN_COMMAND="load_picframe"
fi

get_status() {
  if pgrep -u $LOGNAME -x luakit > /dev/null; then
    echo Pics
    return 0
  else
    echo Down
    return 1
  fi
}

export WAYLAND_DISPLAY=wayland-1
export SWAYSOCK=/run/user/$EUID/sway-ipc.$EUID.$(pgrep -u $LOGNAME -x sway).sock
case "$RUN_COMMAND" in
  "reload")
    echo Reloading picture frame URL
    /usr/bin/firejail --join-or-start=luakit /usr/bin/luakit "https://picframe.erdely.in"
    exit $?
    ;;
  "restart")
    echo Restarting picture frame browser
    $HOME/.local/bin/restart_luakit
    exit $?
    ;;
  "reboot")
    echo Rebooting picture frame system
    sudo /sbin/reboot.no-molly-guard
    exit $?
    ;;
  *)
    get_status
    exit $?
    ;;
esac
