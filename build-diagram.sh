#!/bin/bash
# Build diagram from Mermaid source

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGRAM_FILE="$SCRIPT_DIR/diagram.mermaid"
OUTPUT_FILE="$SCRIPT_DIR/diagram.png"

if [ ! -f "$DIAGRAM_FILE" ]; then
    echo "Error: $DIAGRAM_FILE not found"
    exit 1
fi

# Check if mermaid-cli is installed
if command -v mmdc &> /dev/null; then
    echo "Building diagram with mermaid-cli..."
    mmdc -i "$DIAGRAM_FILE" -o "$OUTPUT_FILE"
    echo "Diagram saved to: $OUTPUT_FILE"
else
    echo "mermaid-cli not installed. Installing..."
    npm install -g @mermaid-js/mermaid-cli
    mmdc -i "$DIAGRAM_FILE" -o "$OUTPUT_FILE"
    echo "Diagram saved to: $OUTPUT_FILE"
fi