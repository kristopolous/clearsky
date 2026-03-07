{ pkgs, run-container }:

pkgs.writeShellScriptBin "setup-owncloud" ''
  set -e

  HOST="http://localhost:8081"
  PORT="8081"
  ADMIN_USER="admin"
  ADMIN_PASS=""
  DATA_DIR="$HOME/.clearsky/owncloud"

  while [ $# -gt 0 ]; do
    case "$1" in
      --host) HOST="$2"; shift 2 ;;
      --port) PORT="$2"; shift 2 ;;
      --admin-user) ADMIN_USER="$2"; shift 2 ;;
      --admin-pass) ADMIN_PASS="$2"; shift 2 ;;
      --data-dir) DATA_DIR="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  mkdir -p "$DATA_DIR"

  echo "Setting up ownCloud..."

  # Check if ownCloud is already running
  if curl -s "$HOST" > /dev/null 2>&1; then
    echo "ownCloud is already running at $HOST"
    echo "Access it at: $HOST"
    exit 0
  fi

  # Start ownCloud container using run-container harness
  ${run-container}/bin/run-container \
    --name owncloud \
    --image docker.io/owncloud/server:latest \
    --port "$PORT" \
    --volume "$DATA_DIR:/var/www/html" \
    --env "OWNCLOUD_ADMIN_USER=$ADMIN_USER" \
    --env "OWNCLOUD_ADMIN_PASSWORD=${ADMIN_PASS:-admin123}" \
    --env "OWNCLOUD_DOMAIN=localhost"

  # Wait for ownCloud to start
  echo "Waiting for ownCloud to start..."
  for i in {1..60}; do
    if curl -s "$HOST" > /dev/null 2>&1; then
      echo "ownCloud started successfully!"
      break
    fi
    sleep 2
  done

  echo ""
  echo "=========================================="
  echo "ownCloud is now running!"
  echo "=========================================="
  echo "URL: $HOST"
  echo "Admin User: $ADMIN_USER"
  echo "Admin Password: ${ADMIN_PASS:-admin123}"
  echo ""
  echo "Please change the default password after login!"
  echo "=========================================="
''
