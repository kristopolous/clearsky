{ pkgs, run-container }:

pkgs.writeShellScriptBin "import-etherpad" ''
  set -e

  INPUT=""
  HOST="http://localhost:9001"
  PORT="9001"
  API_KEY=""
  DATA_DIR="$HOME/.clearsky/etherpad"

  while [ $# -gt 0 ]; do
    case "$1" in
      --input) INPUT="$2"; shift 2 ;;
      --host) HOST="$2"; shift 2 ;;
      --port) PORT="$2"; shift 2 ;;
      --api-key) API_KEY="$2"; shift 2 ;;
      --data-dir) DATA_DIR="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  if [ -z "$INPUT" ]; then
    echo "Usage: import-etherpad --input DIR [--host URL] [--port PORT] [--api-key KEY]"
    exit 1
  fi

  # Check if Etherpad is running
  if ! curl -s "$HOST/api" > /dev/null; then
    echo "Etherpad is not running at $HOST"
    echo "Starting Etherpad..."

    # Start Etherpad container using run-container harness
    ${run-container}/bin/run-container \
      --name etherpad \
      --image docker.io/etherpad/etherpad:latest \
      --port "$PORT" \
      --volume "$DATA_DIR:/opt/etherpad-lite/var" \
      --env "TITLE=Clearsky Etherpad"

    # Wait for Etherpad to start
    for i in {1..30}; do
      if curl -s "$HOST/api" > /dev/null; then
        echo "Etherpad started successfully"
        break
      fi
      sleep 1
    done
  fi

  # Import documents
  echo "Importing documents from $INPUT to Etherpad..."
  
  # Find all HTML and TXT files
  find "$INPUT" -type f \( -name "*.html" -o -name "*.txt" -o -name "*.md" \) | while read -r file; do
    filename=$(basename "$file")
    padname="doc_${filename%.*}"
    
    echo "Importing: $filename -> $padname"
    
    # Create pad via API
    if [ -n "$API_KEY" ]; then
      curl -s "$HOST/api/1/createPad?apikey=$API_KEY&padID=$padname" > /dev/null
      # Import content
      curl -s -X POST -F "file=@$file" "$HOST/api/1/createPad?apikey=$API_KEY&padID=$padname" > /dev/null
    else
      # Without API key, just copy files to import directory
      mkdir -p "$HOME/.clearsky/etherpad/imports"
      cp "$file" "$HOME/.clearsky/etherpad/imports/"
    fi
  done

  echo "Import complete!"
''
