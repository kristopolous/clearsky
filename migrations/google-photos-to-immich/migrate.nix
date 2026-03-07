{ pkgs, download, extract, import-immich, google-photos-download }:

pkgs.stdenv.mkDerivation {
  name = "google-photos-to-immich";
  version = "2.0.0";

  buildInputs = [
    pkgs.curl
    pkgs.unzip
    pkgs.immich-go
    pkgs.jq
  ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    echo "Starting Google Photos migration..."

    # Check for API key or ZIP file
    API_KEY="${GOOGLE_PHOTOS_API_KEY:-}"
    ZIP_FILE="${GOOGLE_PHOTOS_ZIP:-}"
    TMPDIR=$(mktemp -d)
    EXTRACT_DIR="$TMPDIR/extracted"
    DOWNLOAD_DIR="$TMPDIR/downloaded"

    mkdir -p "$DOWNLOAD_DIR"
    mkdir -p "$EXTRACT_DIR"

    # Step 1: Download photos (API or manual)
    if [ -n "$API_KEY" ]; then
      echo "Downloading photos from Google Photos API..."
      ${google-photos-download}/bin/google-photos-download \
        --api-key "$API_KEY" \
        --output "$DOWNLOAD_DIR"
    elif [ -n "$ZIP_FILE" ]; then
      echo "Using provided ZIP file: $ZIP_FILE"
      cp "$ZIP_FILE" "$TMPDIR/export.zip"
    else
      echo "No API key or ZIP file provided."
      echo "Please provide GOOGLE_PHOTOS_API_KEY or GOOGLE_PHOTOS_ZIP environment variable"
      echo "Or download from https://takeout.google.com and provide the ZIP file path"
      exit 1
    fi

    # Step 2: Extract if ZIP file
    if [ -n "$ZIP_FILE" ] || [ -z "$API_KEY" ]; then
      if [ -f "$TMPDIR/export.zip" ]; then
        echo "Extracting export..."
        ${extract}/bin/extract \
          --input "$TMPDIR/export.zip" \
          --output "$EXTRACT_DIR"
      else
        # API download - files are already in DOWNLOAD_DIR
        EXTRACT_DIR="$DOWNLOAD_DIR"
      fi
    fi

    # Step 3: Import photos (this will start Immich if needed)
    echo "Importing photos to Immich..."
    ${import-immich}/bin/import-immich \
      --input "$EXTRACT_DIR" \
      --host "http://localhost:2283"

    # Cleanup
    rm -rf "$TMPDIR"

    echo "Migration complete! Your photos are now in Immich."
    echo "Access Immich at: http://localhost:2283"
    EOF

    chmod +x $out/bin/migrate
  '';
}
