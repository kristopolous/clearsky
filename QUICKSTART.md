# Clearsky
No More Clouds

A desktop application for migrating data from cloud services to self-hosted alternatives.

## Features

- 📸 Migrate Google Photos to Immich
- 📁 Migrate Google Drive/Docs to self-hosted storage
- 🔐 All data stays on your machine
- 🔄 Easy rollback if something goes wrong
- 🌐 Optional Tailscale remote access

## Requirements

- Linux (Ubuntu 20.04+, NixOS, or other modern distro)
- Podman 4.0+
- 2GB free disk space
- Internet connection for initial setup

## Installation

### AppImage

```bash
wget https://github.com/clearsky/clearsky/releases/download/v1.0.0/Clearsky.AppImage
chmod +x Clearsky.AppImage
./Clearsky.AppImage
```

### From Source

```bash
git clone https://github.com/clearsky/clearsky.git
cd clearsky
nix-shell
npm install
npm start
```

## Usage

1. Launch Clearsky
2. Select services to migrate from
3. Follow export instructions
4. Drag and drop your export files
5. Watch the import progress
6. Preview your data
7. Commit migration

## Development

```bash
# Install dependencies
npm install

# Run in dev mode
npm start

# Build
npm run build
```

## License

MIT