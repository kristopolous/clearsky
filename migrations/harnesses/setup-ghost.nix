{ pkgs, run-container }:

pkgs.writeShellScriptBin "setup-ghost" ''
  set -e

  HOST="http://localhost:2368"
  ADMIN_URL="http://localhost:2368/ghost"
  DATA_DIR="$HOME/.clearsky/ghost"
  MYSQL_ROOT_PASSWORD="ghost_mysql_root_password"
  MYSQL_DATABASE="ghost"
  MYSQL_USER="ghost"
  MYSQL_PASSWORD="ghost_password"

  while [ $# -gt 0 ]; do
    case "$1" in
      --host) HOST="$2"; shift 2 ;;
      --data-dir) DATA_DIR="$2"; shift 2 ;;
      --mysql-root-password) MYSQL_ROOT_PASSWORD="$2"; shift 2 ;;
      --mysql-password) MYSQL_PASSWORD="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  mkdir -p "$DATA_DIR"

  echo "Setting up Ghost..."

  # Check if Ghost is already running
  if curl -s "$HOST" > /dev/null 2>&1; then
    echo "Ghost is already running at $HOST"
    echo "Admin URL: $ADMIN_URL"
    exit 0
  fi

  # Start MySQL container for Ghost
  echo "Starting MySQL container..."
  ${run-container}/bin/run-container \
    --name ghost-mysql \
    --image docker.io/library/mysql:8.0 \
    --volume "$DATA_DIR/mysql:/var/lib/mysql" \
    --env "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    --env "MYSQL_DATABASE=$MYSQL_DATABASE" \
    --env "MYSQL_USER=$MYSQL_USER" \
    --env "MYSQL_PASSWORD=$MYSQL_PASSWORD"

  # Wait for MySQL to start
  echo "Waiting for MySQL to start..."
  for i in {1..30}; do
    if ${run-container}/bin/run-container --help > /dev/null 2>&1 && \
       docker exec ghost-mysql mysqladmin ping -u root -p"$MYSQL_ROOT_PASSWORD" > /dev/null 2>&1; then
      echo "MySQL is ready"
      break
    fi
    sleep 2
  done

  # Start Ghost container
  echo "Starting Ghost container..."
  ${run-container}/bin/run-container \
    --name ghost \
    --image docker.io/library/ghost:5-alpine \
    --port 2368 \
    --volume "$DATA_DIR/ghost:/var/lib/ghost/content" \
    --env "database__client=mysql" \
    --env "database__connection__host=ghost-mysql" \
    --env "database__connection__user=$MYSQL_USER" \
    --env "database__connection__password=$MYSQL_PASSWORD" \
    --env "database__connection__database=$MYSQL_DATABASE" \
    --env "url=$HOST"

  # Wait for Ghost to start
  echo "Waiting for Ghost to start (up to 60 seconds)..."
  for i in {1..60}; do
    if curl -s "$HOST" > /dev/null 2>&1; then
      echo "Ghost started successfully!"
      break
    fi
    if [ $((i % 10)) -eq 0 ]; then
      echo "Still waiting... ($i seconds)"
    fi
    sleep 1
  done

  echo ""
  echo "=========================================="
  echo "Ghost is now running!"
  echo "=========================================="
  echo "Blog URL: $HOST"
  echo "Admin URL: $ADMIN_URL"
  echo ""
  echo "First-time setup:"
  echo "1. Open $ADMIN_URL in your browser"
  echo "2. Create your admin account"
  echo "3. Configure your blog settings"
  echo "4. Start importing your content"
  echo ""
  echo "=========================================="
''
