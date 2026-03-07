{ pkgs }:

pkgs.writeShellScriptBin "import-etherpad" ''
  set -e

  INPUT=""
  HOST="http://localhost:9001"
  API_KEY=""

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
      --api-key)
        API_KEY="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  if [ -z "$INPUT" ]; then
    echo "Usage: import-etherpad --input DIR [--host URL] [--api-key KEY]"
    exit 1
  fi

  # Check if Etherpad is running
  if ! curl -s "$HOST/api" > /dev/null; then
    echo "Etherpad is not running at $HOST"
    echo "Starting Etherpad..."

    # Start Etherpad container
    podman run -d --name etherpad -p 9001:9001 \
      -e TITLE="Clearsky Etherpad" \
      -v "$HOME/.clearsky/etherpad:/opt/etherpad-lite/var" \
      etherpad/etherpad:latest

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
      cp "$file" "$HOME/.clearsky/etherpad/imports/"
    fi
  done

  echo "Import complete!"
''
