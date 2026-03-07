{ pkgs, run-container }:

pkgs.writeShellScriptBin "setup-nextcloud" ''
  set -e

  HOST="http://localhost:8080"
  PORT="8080"
  ADMIN_USER="admin"
  ADMIN_PASS=""
  DATA_DIR="$HOME/.clearsky/nextcloud"

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

  echo "Setting up Nextcloud..."

  # Check if Nextcloud is already running
  if curl -s "$HOST" > /dev/null 2>&1; then
    echo "Nextcloud is already running at $HOST"
    echo "Access it at: $HOST"
    exit 0
  fi

  # Start Nextcloud container using run-container harness
  ${run-container}/bin/run-container \
    --name nextcloud \
    --image docker.io/library/nextcloud:latest \
    --port "$PORT" \
    --volume "$DATA_DIR:/var/www/html" \
    --env "NEXTCLOUD_ADMIN_USER=$ADMIN_USER" \
    --env "NEXTCLOUD_ADMIN_PASSWORD=${ADMIN_PASS:-admin123}"

  # Wait for Nextcloud to start
  echo "Waiting for Nextcloud to start..."
  for i in {1..60}; do
    if curl -s "$HOST" > /dev/null 2>&1; then
      echo "Nextcloud started successfully!"
      break
    fi
    sleep 2
  done

  echo ""
  echo "=========================================="
  echo "Nextcloud is now running!"
  echo "=========================================="
  echo "URL: $HOST"
  echo "Admin User: $ADMIN_USER"
  echo "Admin Password: ${ADMIN_PASS:-admin123}"
  echo ""
  echo "Please change the default password after login!"
  echo "=========================================="
''
