{ pkgs }:

pkgs.writeShellScriptBin "extract" ''
  set -e

  INPUT=""
  OUTPUT=""
  FORMAT="zip"

  while [ $# -gt 0 ]; do
    case "$1" in
      --input)
        INPUT="$2"
        shift 2
        ;;
      --output)
        OUTPUT="$2"
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

  if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: extract --input FILE --output DIR [--format FORMAT]"
    exit 1
  fi

  mkdir -p "$OUTPUT"

  case "$FORMAT" in
    zip)
      unzip -q "$INPUT" -d "$OUTPUT"
      ;;
    tar|tar.gz|tgz)
      tar -xzf "$INPUT" -C "$OUTPUT"
      ;;
    tar.bz2)
      tar -xjf "$INPUT" -C "$OUTPUT"
      ;;
    *)
      echo "Unknown format: $FORMAT"
      exit 1
      ;;
  esac
''
