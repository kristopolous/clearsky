{ pkgs }:

pkgs.writeShellScriptBin "import-ghost" ''
  set -e

  INPUT=""
  HOST="http://localhost:2368"
  ADMIN_URL="http://localhost:2368/ghost"

  while [ $# -gt 0 ]; do
    case "$1" in
      --input) INPUT="$2"; shift 2 ;;
      --host) HOST="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  if [ -z "$INPUT" ]; then
    echo "Usage: import-ghost --input DIR [--host URL]"
    exit 1
  fi

  echo "Importing content to Ghost..."
  echo ""
  echo "=========================================="
  echo "Ghost Import Instructions"
  echo "=========================================="
  echo ""
  echo "Your export files are ready at: $INPUT"
  echo ""
  echo "To import into Ghost:"
  echo ""
  echo "1. Open Ghost Admin: $ADMIN_URL"
  echo "2. Go to Settings → Advanced"
  echo "3. Click 'Import content'"
  echo "4. Select your export file:"
  echo ""
  
  # Find export files
  if [ -f "$INPUT/substack-export.csv" ]; then
    echo "   - Substack export: $INPUT/substack-export.csv"
  fi
  
  if [ -f "$INPUT/medium-export.zip" ]; then
    echo "   - Medium export: $INPUT/medium-export.zip"
  fi
  
  # Find any CSV or ZIP files
  find "$INPUT" -maxdepth 1 -type f \( -name "*.csv" -o -name "*.zip" -o -name "*.json" \) | while read -r file; do
    echo "   - $(basename "$file")"
  done
  
  echo ""
  echo "Ghost supports:"
  echo "  - CSV files (Substack, Medium)"
  echo "  - JSON files (Ghost JSON)"
  echo "  - ZIP archives (Medium)"
  echo ""
  echo "=========================================="
''
