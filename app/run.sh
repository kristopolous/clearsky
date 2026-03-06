#!/bin/bash

# Clearsky AppImage launcher
# This script handles the setup and launch of the Clearsky application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR"

echo "🚀 Clearsky: No More Clouds"
echo "============================"
echo ""

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    echo "⚠️  Podman is not installed."
    echo ""
    echo "Please install Podman first:"
    echo ""
    echo "  Ubuntu/Debian: sudo apt install podman"
    echo "  Fedora:        sudo dnf install podman"
    echo "  Arch Linux:    sudo pacman -S podman"
    echo "  NixOS:         nix-env -iA nixos.podman"
    echo ""
    echo "Or visit: https://podman.io/getting-started/installation"
    exit 1
fi

echo "✓ Podman found: $(podman --version)"
echo ""

# Create data directory
DATA_DIR="$HOME/.clearsky"
mkdir -p "$DATA_DIR"
echo "✓ Data directory: $DATA_DIR"
echo ""

# Start Immich container
echo "🚀 Starting Immich container..."
CONTAINER_ID=$(podman run -d \
    --rm \
    --name clearsky-immich \
    -p 2283:2283 \
    -v "$DATA_DIR/immich:/mnt/data" \
    ghcr.io/immich-app/immich-server:latest)

echo "✓ Immich container started: $CONTAINER_ID"
echo "  Dashboard: http://localhost:2283"
echo ""

# Start Tailscale (optional)
echo "🔄 Setting up Tailscale..."
CONTAINER_ID=$(podman run -d \
    --rm \
    --name clearsky-tailscale \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    -v /dev/net/tun:/dev/net/tun \
    -v "$DATA_DIR/tailscale:/run" \
    tailscale/tailscale:latest \
    tailnet --state-dir=/run/tailscale)

echo "✓ Tailscale started"
echo "  Access your services securely from anywhere"
echo ""

# Open dashboard
echo "🌐 Opening Immich dashboard..."
if command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:2283"
elif command -v open &> /dev/null; then
    open "http://localhost:2283"
fi

echo ""
echo "✨ Clearsky is running!"
echo "  - Immich: http://localhost:2283"
echo "  - Data: $DATA_DIR"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Keep running and show logs
podman logs -f clearsky-immich 2>/dev/null || true