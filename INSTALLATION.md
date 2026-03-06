# Clearsky: Installation Guide

This guide covers all the ways to install Clearsky.

## Quick Start

```bash
# Option 1: Download and run
wget https://github.com/clearsky/clearsky/releases/download/v1.0.0/Clearsky-1.0.0.AppImage
chmod +x Clearsky-1.0.0.AppImage
./Clearsky-1.0.0.AppImage

# Option 2: Build with Nix
nix build
cp ./result/bin/clearsky ~/Downloads/Clearsky.AppImage
chmod +x ~/Downloads/Clearsky.AppImage
./~/Downloads/Clearsky.AppImage
```

## Detailed Installation Options

### Option 1: Pre-Built AppImage (Easiest)

1. Download the AppImage from the [Releases page](https://github.com/clearsky/clearsky/releases)
2. Make it executable: `chmod +x Clearsky-*.AppImage`
3. Run it: `./Clearsky-*.AppImage`

**Pros:**
- No build required
- All dependencies bundled
- Works on any Linux with AppImage support

**Cons:**
- Requires internet to download
- May need `libfuse2` installed on some systems

### Option 2: Build with Nix (Recommended for NixOS Hackathon)

#### Prerequisites

- Nix package manager installed
  - Install with: `curl -L https://nixos.org/nix/install | sh`
  - Or use multi-user install: `sudo sh <(curl -L https://nixos.org/nix/install) --daemon`

#### Build Steps

```bash
# Clone the repository
git clone https://github.com/clearsky/clearsky.git
cd clearsky

# Build the AppImage
nix build

# The AppImage is at ./result/bin/clearsky
# Copy it to a convenient location
cp ./result/bin/clearsky ~/Downloads/Clearsky.AppImage
chmod +x ~/Downloads/Clearsky.AppImage
```

**Pros:**
- Reproducible builds
- All dependencies verified by Nix
- Works on any Linux system
- Perfect for NixOS Hackathon demo

**Cons:**
- Requires Nix to be installed
- First build downloads many dependencies (~500MB)

### Option 3: Build from Source with npm

#### Prerequisites

- Node.js 18+ installed
- npm (comes with Node.js)
- Podman 4.0+ installed
- electron-builder dependencies

#### Ubuntu/Debian Dependencies

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Podman
sudo apt install -y podman

# Install electron-builder dependencies
sudo apt install -y \
  libasound2 \
  libatk-bridge2.0-0 \
  libatk1.0-0 \
  libc6 \
  libcairo2 \
  libcups2 \
  libdbus-1-3 \
  libdrm2 \
  libexpat1 \
  libfontconfig1 \
  libgcc1 \
  libglib2.0-0 \
  libgtk-3-0 \
  libnspr4 \
  libnss3 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libstdc++6 \
  libx11-6 \
  libx11-xcb1 \
  libxcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxext6 \
  libxfixes3 \
  libxrandr2 \
  libxshmfence1 \
  libxtst6 \
  xdg-utils
```

#### Fedora Dependencies

```bash
# Install Node.js
sudo dnf install -y nodejs

# Install Podman
sudo dnf install -y podman

# Install electron-builder dependencies
sudo dnf install -y \
  alsa-lib \
 atk \
 cairo \
 cairo-gobject \
  cups-libs \
  dbus-libs \
  egl-wayland \
  expat \
  fontconfig \
  freetype \
  glib2 \
  gtk3 \
  libdrm \
  libXcomposite \
  libXcursor \
  libXdamage \
  libXext \
  libXfixes \
  libXi \
  libXrandr \
  libXrender \
  libXtst \
  libxshmfence \
  nss \
  atk \
  pango \
  xorg-x11-server-Xvfb
```

#### Build Steps

```bash
# Clone the repository
git clone https://github.com/clearsky/clearsky.git
cd clearsky

# Install npm dependencies
cd app
npm install

# Build the AppImage
npm run build

# The AppImage is in ./dist/
ls -lh dist/Clearsky-*.AppImage
```

## Running Clearsky

### First Run

1. Launch Clearsky: `./Clearsky.AppImage`
2. The app will check if Podman is installed
3. If not, follow the on-screen instructions to install it

### After Podman Installation

1. Launch Clearsky
2. Select services (Google Photos, Google Drive, iCloud)
3. Export data from cloud services
4. Import data to local services
5. Set up remote access with Tailscale (optional)

## System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| OS | Linux kernel 4.4+ | Linux kernel 5.15+ |
| RAM | 2GB | 4GB+ |
| Disk Space | 500MB | 10GB+ (for data) |
| Architecture | x86_64 | x86_64 or aarch64 |

## Troubleshooting

### AppImage doesn't run

**Error:** "AppImage can't be executed"

**Solutions:**
1. Make it executable: `chmod +x Clearsky-*.AppImage`
2. Install libfuse2: `sudo apt install libfuse2` (Ubuntu/Debian)
3. Try the npm build instead: `cd app && npm run build`

### Podman not found

**Error:** "Podman is not installed"

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install podman

# Fedora
sudo dnf install podman

# Arch Linux
sudo pacman -S podman
```

### Port already in use

**Error:** "Port 2283 is already in use"

**Solution:**
```bash
# Find and stop the process
sudo lsof -i :2283
sudo kill -9 <PID>
```

### Import fails

**Error:** "Import failed" or "ZIP file corrupted"

**Solutions:**
1. Make sure ZIP is from Google Takeout
2. Check ZIP file size (very large files may fail)
3. Try importing smaller batches
4. Check logs in `~/.clearsky/logs/`

### Build fails with Nix

**Error:** "hash mismatch" or "build failed"

**Solution:**
```bash
# Clear Nix cache
nix-collect-garbage

# Rebuild
nix build --refresh
```

## Uninstallation

### Remove AppImage

```bash
# Just delete the file
rm ~/Downloads/Clearsky.AppImage
```

### Remove Data

```bash
# Clear user data (photos, config, etc.)
rm -rf ~/.clearsky
```

## Getting Help

- GitHub Issues: [https://github.com/clearsky/clearsky/issues](https://github.com/clearsky/clearsky/issues)
- Documentation: [https://github.com/clearsky/clearsky/wiki](https://github.com/clearsky/clearsky/wiki)