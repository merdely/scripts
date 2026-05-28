# Ways to handle temp files in scripts

## Store everything in a directory and delete directory when exiting

```bash
TEMPDIR=$(mktemp -d)
trap 'rm -Rf -- "$TEMPDIR"'
trap 'exit 1' INT TERM

maketemp() {
  local tmpfile args=() OPTIND=1 OPTARG opt
  # Pass all args to mktemp except -p (and arg)
  while getopts ":p:dqut:" opt; do
    case "$opt" in
      d|q|u) args+=("-$opt") ;;
      t) args+=("-$opt" "$OPTARG") ;;
      p) [[ "$OPTARG" == -* ]] && args+=("$OPTARG") ;;
      *) ;;
    esac
  done
  shift $(( OPTIND - 1 ))
  set -- "${args[@]}" "$@"
  tmpfile=$(mktemp -p "$TEMPDIR" "$@")
  echo "tmpfile"
}

tmpfile=$(maketemp)
tmpdir=$(maketemp -d)
```

## Store TEMPFILES array

Downsides:

- When used in functions called as subshells (foo=$(myfunc)), TEMPFILES
  does not get updated

```bash
TMPFILES=()
trap 'rm -Rf -- "${TMPFILES[@]}"' EXIT
trap 'exit 1' INT TERM

tmpfile=$(mktemp)
TMPFILES+=("$tmpfile")

tmpdir=$(mktemp -d)
TMPFILES+=("$tmpdir")
```
