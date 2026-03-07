{ pkgs, download, extract, import-ghost }:

pkgs.stdenv.mkDerivation {
  name = "substack-to-ghost";
  version = "1.0.0";

  buildInputs = [
    pkgs.curl
    pkgs.unzip
  ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    echo "Starting Substack to Ghost migration..."
    echo ""

    # Get configuration from environment or use defaults
    ZIP_FILE="${SUBSTACK_ZIP:-}"
    EXTRACT_DIR="${SUBSTACK_EXTRACT_DIR:-$TMPDIR/extracted}"

    TMPDIR=$(mktemp -d)
    
    if [ -z "$EXTRACT_DIR" ]; then
      EXTRACT_DIR="$TMPDIR/extracted"
    fi

    mkdir -p "$EXTRACT_DIR"

    # Step 1: Check for ZIP file
    if [ -n "$ZIP_FILE" ]; then
      echo "Using provided ZIP file: $ZIP_FILE"
      if [ -f "$ZIP_FILE" ]; then
        cp "$ZIP_FILE" "$TMPDIR/substack-export.zip"
      else
        echo "Error: ZIP file not found: $ZIP_FILE"
        exit 1
      fi
    else
      echo "No ZIP file provided."
      echo ""
      echo "To export from Substack:"
      echo "1. Go to your Substack dashboard"
      echo "2. Go to Settings → Advanced"
      echo "3. Click 'Export data'"
      echo "4. Download the CSV file"
      echo "5. Run again with SUBSTACK_ZIP=/path/to/export.zip"
      echo ""
      echo "Or provide the CSV file path directly."
      exit 1
    fi

    # Step 2: Extract
    echo "Extracting export..."
    ${extract}/bin/extract \
      --input "$TMPDIR/substack-export.zip" \
      --output "$EXTRACT_DIR"

    # Step 3: Import to Ghost
    echo "Preparing import to Ghost..."
    ${import-ghost}/bin/import-ghost \
      --input "$EXTRACT_DIR"

    # Cleanup
    rm -rf "$TMPDIR"

    echo ""
    echo "Migration preparation complete!"
    echo "Follow the on-screen instructions to import into Ghost."
    EOF

    chmod +x $out/bin/migrate
  '';
}
