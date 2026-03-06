# Clearsky: No More Clouds

A user-friendly desktop application that guides non-technical users through migrating their data from cloud services to self-hosted, privacy-focused alternatives.

## Features

- 🎯 **Simple Migration Wizard** - Step-by-step guided process for migrating data
- 📸 **Google Photos → Immich** - Export and import photos with album preservation
- 📁 **Google Drive / Docs** - Migrate documents to self-hosted storage
- 🔐 **Privacy First** - All data stays on your machine, no cloud required
- 🔄 **Easy Rollback** - Undo migrations with a single click
- 🌐 **Remote Access** - Tailscale integration for secure remote access

## Prerequisites

- Linux (Ubuntu 20.04+, NixOS, or other modern distro)
- Podman 4.0+ (for containerized services)
- Electron (for the desktop app)

## Quick Start

### Option 1: Using AppImage

```bash
# Download the AppImage
wget https://github.com/clearsky/clearsky/releases/download/v1.0.0/Clearsky.AppImage

# Make it executable
chmod +x Clearsky.AppImage

# Run it
./Clearsky.AppImage
```

### Option 2: From Source

```bash
# Clone the repository
git clone https://github.com/clearsky/clearsky.git
cd clearsky

# Install dependencies
nix-shell

# Build and run
npm start
```

### Option 3: Using Nix

```bash
# Build the AppImage
nix build .#appimage

# Run the app
./result/bin/clearsky
```

## Usage

1. **Launch Clearsky** - Double-click the AppImage or run `clearsky`
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
├── flake.nix              # Nix flake configuration
├── default.nix            # Nix build expression
└── run.sh                 # AppImage launcher script
```

## Development

### Prerequisites

- Nix package manager
- Node.js 18+
- Podman

### Setup

```bash
# Enter development shell
nix-shell

# Install dependencies
npm install

# Run in development mode
npm start
```

### Building AppImage

```bash
# Build using Nix
nix build .#appimage

# Or using npm
npm run build
```

## Troubleshooting

### Podman not found

Install Podman:
```bash
# Ubuntu/Debian
sudo apt install podman

# Fedora
sudo dnf install podman

# Arch Linux
sudo pacman -S podman
```

### Port 2283 already in use

```bash
# Check what's using the port
lsof -i :2283

# Stop the conflicting service or restart Podman
podman restart clearsky-immich
```

### Import fails

- Make sure your ZIP file is from Google Takeout
- Check that the file isn't corrupted
- Try importing smaller batches if the file is very large

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

## Contact

- GitHub: [https://github.com/clearsky/clearsky](https://github.com/clearsky/clearsky)
- Issues: [https://github.com/clearsky/clearsky/issues](https://github.com/clearsky/clearsky/issues)

---

**Clearsky**: Reclaim your data. Take back your privacy. 🌤️