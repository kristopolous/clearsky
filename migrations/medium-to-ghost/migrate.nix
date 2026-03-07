{ pkgs, download, extract, import-ghost }:

pkgs.stdenv.mkDerivation {
  name = "medium-to-ghost";
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

    echo "Starting Medium to Ghost migration..."
    echo ""

    # Get configuration from environment or use defaults
    ZIP_FILE="${MEDIUM_ZIP:-}"
    EXTRACT_DIR="${MEDIUM_EXTRACT_DIR:-$TMPDIR/extracted}"

    TMPDIR=$(mktemp -d)
    
    if [ -z "$EXTRACT_DIR" ]; then
      EXTRACT_DIR="$TMPDIR/extracted"
    fi

    mkdir -p "$EXTRACT_DIR"

    # Step 1: Check for ZIP file
    if [ -n "$ZIP_FILE" ]; then
      echo "Using provided ZIP file: $ZIP_FILE"
      if [ -f "$ZIP_FILE" ]; then
        cp "$ZIP_FILE" "$TMPDIR/medium-export.zip"
      else
        echo "Error: ZIP file not found: $ZIP_FILE"
        exit 1
      fi
    else
      echo "No ZIP file provided."
      echo ""
      echo "To export from Medium:"
      echo "1. Go to medium.com/settings"
      echo "2. Scroll to 'Your account'"
      echo "3. Click 'Download your information'"
      echo "4. Wait for the email with your download link"
      echo "5. Download the ZIP file"
      echo "6. Run again with MEDIUM_ZIP=/path/to/export.zip"
      echo ""
      exit 1
    fi

    # Step 2: Extract
    echo "Extracting export..."
    ${extract}/bin/extract \
      --input "$TMPDIR/medium-export.zip" \
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
