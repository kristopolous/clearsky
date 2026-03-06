{ pkgs }:

pkgs.writeShellScriptBin "import-immich" ''
  set -e

  INPUT=""
  HOST="http://localhost:2283"
  KEY="dummy"

  while [ $# -gt 0 ]; do
    case "$1" in
      --input)
        INPUT="$2"
        shift 2
        ;;
      --host)
        HOST="$2"
        shift 2
        ;;
      --key)
        KEY="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  if [ -z "$INPUT" ]; then
    echo "Usage: import-immich --input DIR [--host URL] [--key KEY]"
    exit 1
  fi

  # Check if Immich is running
  if ! curl -s "$HOST/api/health" > /dev/null; then
    echo "Immich is not running at $HOST"
    echo "Starting Immich..."

    # Start Immich container
    podman run -d --name immich -p 2283:2283 \
      -v "$HOME/.clearsky/immich:/mnt/data" \
      ghcr.io/immich-app/immich-server:latest

    # Wait for Immich to start
    for i in {1..30}; do
      if curl -s "$HOST/api/health" > /dev/null; then
        echo "Immich started successfully"
        break
      fi
      sleep 1
    done
  fi

  # Import photos
  echo "Importing photos from $INPUT to Immich..."
  immich-go import --input "$INPUT" --host "$HOST" --key "$KEY"
''
