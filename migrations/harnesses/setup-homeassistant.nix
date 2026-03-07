{ pkgs, run-container }:

pkgs.writeShellScriptBin "setup-homeassistant" ''
  set -e

  HOST="http://localhost:8123"
  PORT="8123"
  DATA_DIR="$HOME/.clearsky/homeassistant"

  while [ $# -gt 0 ]; do
    case "$1" in
      --host) HOST="$2"; shift 2 ;;
      --port) PORT="$2"; shift 2 ;;
      --data-dir) DATA_DIR="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  mkdir -p "$DATA_DIR"

  echo "Setting up Home Assistant..."

  # Check if Home Assistant is already running
  if curl -s "$HOST" > /dev/null 2>&1; then
    echo "Home Assistant is already running at $HOST"
    echo "Access it at: $HOST"
    exit 0
  fi

  # Start Home Assistant container using run-container harness
  ${run-container}/bin/run-container \
    --name homeassistant \
    --image ghcr.io/home-assistant/home-assistant:stable \
    --port "$PORT" \
    --volume "$DATA_DIR:/config:rw"

  # Wait for Home Assistant to start (it takes longer)
  echo "Waiting for Home Assistant to start (this may take a few minutes)..."
  for i in {1..120}; do
    if curl -s "$HOST" > /dev/null 2>&1; then
      echo "Home Assistant started successfully!"
      break
    fi
    if [ $((i % 10)) -eq 0 ]; then
      echo "Still starting... ($i seconds)"
    fi
    sleep 1
  done

  echo ""
  echo "=========================================="
  echo "Home Assistant is now running!"
  echo "=========================================="
  echo "URL: $HOST"
  echo ""
  echo "First-time setup:"
  echo "1. Open $HOST in your browser"
  echo "2. Create your user account"
  echo "3. Configure your location and preferences"
  echo "4. Start adding devices and integrations"
  echo ""
  echo "=========================================="
''
