{ pkgs, setup-nextcloud }:

pkgs.stdenv.mkDerivation {
  name = "nextcloud-setup";
  version = "1.0.0";

  buildInputs = [
    pkgs.curl
    pkgs.podman
  ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    echo "Setting up Nextcloud..."
    echo ""

    # Get configuration from environment or use defaults
    HOST="${NEXTCLOUD_HOST:-http://localhost:8080}"
    ADMIN_USER="${NEXTCLOUD_ADMIN_USER:-admin}"
    ADMIN_PASS="${NEXTCLOUD_ADMIN_PASSWORD:-}"

    ${setup-nextcloud}/bin/setup-nextcloud \
      --host "$HOST" \
      --admin-user "$ADMIN_USER" \
      --admin-pass "$ADMIN_PASS"

    echo ""
    echo "Nextcloud setup complete!"
    echo ""
    echo "What is Nextcloud?"
    echo "  - File storage and sharing"
    echo "  - Calendar and contacts sync"
    echo "  - Document collaboration"
    echo "  - Video calls and chat"
    echo "  - Hundreds of apps via the app store"
    echo ""
    echo "Access your Nextcloud at: $HOST"
    EOF

    chmod +x $out/bin/migrate
  '';
}
