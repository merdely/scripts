# Use flock to prevent a script from running twice concurrently

## Set filehandle 9 for the script's PID to the lock file

```bash
exec 9> "$HOME/.cache/${0##*/}.lock"
```

## Try to lock using the filehandle and bail if it locked

```bash
flock -n 9 || { echo "${0##*/} already running" >&2 ; exit 1; }
```

