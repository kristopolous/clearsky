<p align="center">
  <img width=560 src=https://github.com/user-attachments/assets/6353c265-aeef-463c-96e6-4e5298289678>
<br/>
</p>
**Clearsky** is a user-friendly desktop application that guides non-technical users through migrating their data from cloud services to self-hosted, privacy-focused alternatives.

**Built for the NixOS Hackathon** - showcasing Nix's power for reproducible, self-contained desktop applications.

## Features

- 🎯 **Simple Migration Wizard** - Step-by-step guided process for migrating data
- 📸 **Google Photos → Immich** - Export and import photos with album preservation
- 📁 **Google Drive / Docs** - Migrate documents to self-hosted storage
- 🔐 **Privacy First** - All data stays on your machine, no cloud required
- 🔄 **Easy Rollback** - Undo migrations with a single click
- 🌐 **Remote Access** - Tailscale integration for secure remote access
- 📦 **Self-Contained AppImage** - Everything bundled via Nix, no system dependencies needed

## Prerequisites

- Linux (Ubuntu 20.04+, NixOS, or other modern distro)
- Podman 4.0+ (for running containers)
- 2GB free disk space

## Installation

### Option 1: Download Pre-Built AppImage

```bash
# Download the AppImage (replace URL with actual release URL when available)
wget https://github.com/clearsky/clearsky/releases/download/v1.0.0/Clearsky-1.0.0.AppImage

# Make it executable
chmod +x Clearsky-1.0.0.AppImage

# Run it
./Clearsky-1.0.0.AppImage
```

### Option 2: Build from Source with Nix (Recommended)

```bash
# Install Nix if you haven't already
curl --proto '=https' --tlsv1.2 -sSf -L https://install.nixos.sh | sh

# Clone the repository
git clone https://github.com/clearsky/clearsky.git
cd clearsky

# Build the AppImage
nix build

# The AppImage will be at ./result/bin/clearsky
cp ./result/bin/clearsky ~/Downloads/Clearsky.AppImage
chmod +x ~/Downloads/Clearsky.AppImage
```

### Option 3: Build from Source without Nix

```bash
# Clone the repository
git clone https://github.com/clearsky/clearsky.git
cd clearsky

# Install dependencies
cd app
npm install

# Build the AppImage
npm run build

# The AppImage will be in ./dist/
```

## Usage

1. **Launch Clearsky** - Double-click the AppImage or run `./Clearsky.AppImage`
2. **Select Services** - Choose which cloud services you want to migrate from
3. **Export Data** - Follow the guide to export your data (e.g., from takeout.google.com)
4. **Upload Files** - Drag and drop your exported ZIP files into the app
5. **Import** - Watch the progress as your data is imported to local services
6. **Set Up Remote Access** - Optionally configure Tailscale for remote access
7. **Preview & Commit** - Review your migrated data and commit the changes

## Services

### Immich (Photos)
- Photo management with albums, faces, and search
- Runs on `http://localhost:2283`
- Data stored in `~/.clearsky/immich`

### Tailscale (Remote Access)
- Secure VPN for accessing your services from anywhere
- Runs as a containerized client
- Configuration stored in `~/.clearsky/tailscale`

## Project Structure

```
clearsky/
├── app/                    # Electron app source
│   ├── main.js            # Electron main process
│   ├── index.html         # Electron renderer (UI)
│   └── package.json       # Node.js dependencies
├── flake.nix              # Nix flake configuration (reproducible builds)
├── appimage.nix           # AppImage build definition
├── default.nix            # Alternative Nix entry point
├── run.sh                 # AppImage launcher script
├── README.md              # This file
└── INSTALLATION.md        # Detailed installation guide
```

## Development

### Prerequisites

- Nix package manager (for reproducible builds)
- Node.js 18+ (for development)
- Podman (for running containers)

### Setup

```bash
# Enter development shell
nix-shell

# Install npm dependencies
npm install

# Run in development mode
npm start
```

### Building AppImage with Nix

```bash
# Build using Nix (bundles all dependencies)
nix build

# Or specify the output
nix build .#appimage
```

### Building AppImage without Nix

```bash
cd app
npm install
npm run build
```

## Troubleshooting

### Podman not found

Clearsky requires Podman to be installed on your system:

```bash
# Ubuntu/Debian
sudo apt install podman

# Fedora
sudo dnf install podman

# Arch Linux
sudo pacman -S podman

# NixOS
nix-env -iA nixos.podman
```

### Port 2283 already in use

```bash
# Check what's using the port
lsof -i :2283

# Stop the conflicting service
podman stop clearsky-immich
```

### Import fails

- Make sure your ZIP file is from Google Takeout
- Check that the file isn't corrupted
- Try importing smaller batches if the file is very large

### AppImage doesn't run on older Linux

The AppImage requires a relatively recent Linux kernel. Try the npm build instead:

```bash
cd app
npm run build
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Electron](https://www.electronjs.org/)
- Containerized with [Podman](https://podman.io/)
- Photo management with [Immich](https://immich.app/)
- Remote access with [Tailscale](https://tailscale.com/)
- Built for the [NixOS Hackathon](https://hackathon.nixos.org/)
- Reproducible builds with [Nix](https://nixos.org/)

## Contact

- GitHub: [https://github.com/clearsky/clearsky](https://github.com/clearsky/clearsky)
- Issues: [https://github.com/clearsky/clearsky/issues](https://github.com/clearsky/clearsky/issues)

---

**Clearsky**: Reclaim your data. Take back your privacy. 🌤️
