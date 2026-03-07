{ pkgs, download, extract, import-etherpad }:

pkgs.stdenv.mkDerivation {
  name = "google-docs-to-etherpad";
  version = "1.0.0";

  buildInputs = [
    pkgs.curl
    pkgs.unzip
    pkgs.podman
  ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    echo "Starting Google Docs to Etherpad migration..."

    # Create temp directory
    TMPDIR=$(mktemp -d)
    EXTRACT_DIR="$TMPDIR/extracted"

    # Step 1: Download Google Takeout
    echo "Downloading Google Docs export..."
    ${download}/bin/download \
      --from "https://takeout.google.com" \
      --to "$TMPDIR" \
      --format "zip"

    # Step 2: Extract
    echo "Extracting export..."
    ${extract}/bin/extract \
      --input "$TMPDIR/export.zip" \
      --output "$EXTRACT_DIR"

    # Step 3: Start Etherpad
    echo "Starting Etherpad..."
    if ! podman ps | grep -q etherpad; then
      podman run -d --name etherpad -p 9001:9001 \
        -e TITLE="Clearsky Etherpad" \
        -v "$HOME/.clearsky/etherpad:/opt/etherpad-lite/var" \
        etherpad/etherpad:latest
    fi

    # Wait for Etherpad to start
    for i in {1..30}; do
      if curl -s "http://localhost:9001/api" > /dev/null; then
        echo "Etherpad started successfully"
        break
      fi
      sleep 1
    done

    # Step 4: Import documents
    echo "Importing documents to Etherpad..."
    ${import-etherpad}/bin/import-etherpad \
      --input "$EXTRACT_DIR" \
      --host "http://localhost:9001"

    # Cleanup
    rm -rf "$TMPDIR"

    echo "Migration complete! Your documents are now in Etherpad."
    echo "Access Etherpad at: http://localhost:9001"
    EOF

    chmod +x $out/bin/migrate
  '';
}
