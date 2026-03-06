{ pkgs, download, extract, import-immich }:

pkgs.stdenv.mkDerivation {
  name = "google-photos-migration";
  version = "1.0.0";
  
  buildInputs = [
    pkgs.curl
    pkgs.unzip
    pkgs.immich-go
    pkgs.podman
  ];
  
  installPhase = ''
    mkdir -p $out/bin
    
    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e
    
    echo "Starting Google Photos migration..."
    
    # Create temp directory
    TMPDIR=$(mktemp -d)
    EXTRACT_DIR="$TMPDIR/extracted"
    
    # Step 1: Download Google Takeout
    echo "Downloading Google Photos export..."
    ${download}/bin/download \
      --from "https://takeout.google.com" \
      --to "$TMPDIR" \
      --format "zip"
    
    # Step 2: Extract
    echo "Extracting export..."
    ${extract}/bin/extract \
      --input "$TMPDIR/export.zip" \
      --output "$EXTRACT_DIR"
    
    # Step 3: Start Immich
    echo "Starting Immich..."
    if ! podman ps | grep -q immich; then
      podman run -d --name immich -p 2283:2283 \
        -v "$HOME/.clearsky/immich:/mnt/data" \
        ghcr.io/immich-app/immich-server:latest
    fi
    
    # Wait for Immich to start
    for i in {1..30}; do
      if curl -s "http://localhost:2283/api/health" > /dev/null; then
        echo "Immich started successfully"
        break
      fi
      sleep 1
    done
    
    # Step 4: Import photos
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