{ pkgs, setup-owncloud }:

pkgs.stdenv.mkDerivation {
  name = "owncloud-setup";
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

    echo "Setting up ownCloud..."
    echo ""

    # Get configuration from environment or use defaults
    HOST="${OWNCLOUD_HOST:-http://localhost:8081}"
    ADMIN_USER="${OWNCLOUD_ADMIN_USER:-admin}"
    ADMIN_PASS="${OWNCLOUD_ADMIN_PASSWORD:-}"

    ${setup-owncloud}/bin/setup-owncloud \
      --host "$HOST" \
      --admin-user "$ADMIN_USER" \
      --admin-pass "$ADMIN_PASS"

    echo ""
    echo "ownCloud setup complete!"
    echo ""
    echo "What is ownCloud?"
    echo "  - File storage and sharing"
    echo "  - Calendar and contacts sync"
    echo "  - Document collaboration"
    echo "  - Video calls and chat"
    echo "  - Enterprise-grade security"
    echo ""
    echo "Access your ownCloud at: $HOST"
    EOF

    chmod +x $out/bin/migrate
  '';
}
