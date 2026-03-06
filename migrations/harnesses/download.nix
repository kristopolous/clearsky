{ pkgs }:

pkgs.writeShellScriptBin "download" ''
  set -e

  FROM=""
  TO=""
  FORMAT="zip"

  while [ $# -gt 0 ]; do
    case "$1" in
      --from)
        FROM="$2"
        shift 2
        ;;
      --to)
        TO="$2"
        shift 2
        ;;
      --format)
        FORMAT="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  if [ -z "$FROM" ] || [ -z "$TO" ]; then
    echo "Usage: download --from URL --to DIR [--format FORMAT]"
    exit 1
  fi

  mkdir -p "$TO"

  case "$FORMAT" in
    zip)
      curl -L "$FROM" -o "$TO/export.zip"
      ;;
    *)
      curl -L "$FROM" -o "$TO/export"
      ;;
  esac
''
