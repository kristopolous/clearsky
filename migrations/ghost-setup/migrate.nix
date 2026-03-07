{ pkgs, setup-ghost }:

pkgs.stdenv.mkDerivation {
  name = "ghost-setup";
  version = "1.0.0";

  buildInputs = [
    pkgs.curl
  ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    echo "Setting up Ghost..."
    echo ""

    # Get configuration from environment or use defaults
    HOST="${GHOST_HOST:-http://localhost:2368}"

    ${setup-ghost}/bin/setup-ghost \
      --host "$HOST"

    echo ""
    echo "Ghost setup complete!"
    echo ""
    echo "What is Ghost?"
    echo "  - Professional publishing platform"
    echo "  - Modern, fast, and SEO-friendly"
    echo "  - Built-in membership and subscriptions"
    echo "  - Newsletter integration"
    echo "  - Clean, minimalist editor"
    echo ""
    echo "Access your Ghost blog at: $HOST"
    echo "Admin panel at: $HOST/ghost"
    EOF

    chmod +x $out/bin/migrate
  '';
}
