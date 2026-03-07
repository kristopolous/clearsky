{ pkgs, setup-homeassistant }:

pkgs.stdenv.mkDerivation {
  name = "homeassistant-setup";
  version = "1.0.0";

  buildInputs = [
    pkgs.curl
  ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    echo "Setting up Home Assistant..."
    echo ""

    # Get configuration from environment or use defaults
    HOST="${HOMEASSISTANT_HOST:-http://localhost:8123}"

    ${setup-homeassistant}/bin/setup-homeassistant \
      --host "$HOST"

    echo ""
    echo "Home Assistant setup complete!"
    echo ""
    echo "What is Home Assistant?"
    echo "  - Home automation platform"
    echo "  - Control lights, thermostats, locks, and more"
    echo "  - Works with 1000+ brands and devices"
    echo "  - Local control - no cloud required"
    echo "  - Powerful automation and scripting"
    echo "  - Voice control via Alexa, Google, or local"
    echo ""
    echo "Access your Home Assistant at: $HOST"
    echo ""
    echo "Note: First startup may take several minutes."
    EOF

    chmod +x $out/bin/migrate
  '';
}
