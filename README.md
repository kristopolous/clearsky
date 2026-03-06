<p align="center">
  <img width=560 src=https://github.com/user-attachments/assets/6353c265-aeef-463c-96e6-4e5298289678>
<br/>
</p>

**Clearsky** is a user-friendly desktop application that guides non-technical users through migrating their data from cloud services to self-hosted, privacy-focused alternatives.

**Built for the NixOS Hackathon** - showcasing Nix's power for reproducible, self-contained desktop applications and modular migration frameworks.

## Features

- 🎯 **Simple Migration Wizard** - Step-by-step guided process for migrating data
- 🧩 **Modular Migration Framework** - Extensible architecture with reusable components
- 📸 **Google Photos → Immich** - Export and import photos with album preservation
- 📁 **Google Drive / Docs** - Migrate documents to self-hosted storage
- 🔐 **Privacy First** - All data stays on your machine, no cloud required
- 🔄 **Easy Rollback** - Undo migrations with a single click
- 🌐 **Remote Access** - Tailscale integration for secure remote access
- 📦 **Self-Contained AppImage** - Everything bundled via Nix, no system dependencies needed

## Architecture

Clearsky uses a **modular migration framework** built on Nix flakes:

```
clearsky/
├── app/                        # Electron application
│   ├── main.js                # Migration orchestrator
│   ├── index.html             # Dynamic UI
│   └── package.json
├── migrations/                 # Migration framework
│   ├── flake.nix              # Standalone migration flake
│   ├── harnesses/             # Reusable components
│   │   ├── download.nix       # Download from source
│   │   ├── extract.nix        # Extract archives
│   │   └── import-immich.nix  # Import to Immich
│   ├── google-photos-to-immich/
│   │   ├── flake.nix
│   │   └── migrate.nix
│   └── registry.nix           # Migration registry
├── flake.nix                   # Main Nix flake
└── appimage.nix                # AppImage build
```

### Migration Framework

Each migration is a self-contained Nix flake that:

- Declares its source and target services
- Uses reusable harnesses (download, extract, import)
- Can be tested independently
- Can be contributed by third parties

**Want to add a migration?** Create a new flake in `migrations/` and register it in `registry.nix`. See [HOWTO.md](migrations/HOWTO.md) for details.

## Prerequisites

- Linux (Ubuntu 20.04+, NixOS 24.11+, or other modern distro)
- Podman 4.0+ (for running containers)
- 2GB free disk space

## Installation

### Option 1: Download Pre-Built AppImage

```bash
# Download the AppImage
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

# The AppImage will be at ./result/Clearsky-1.0.0.AppImage
cp ./result/Clearsky-1.0.0.AppImage ~/Downloads/
chmod +x ~/Downloads/Clearsky-1.0.0.AppImage
```

### Option 3: Build from Source without Nix

```bash
# Clone the repository
git clone https://github.com/clearsky/clearsky.git
cd clearsky/app

# Install dependencies
npm install

# Build the AppImage
npm run build

# The AppImage will be in ./dist/
```

## Usage

1. **Launch Clearsky** - Double-click the AppImage or run `./Clearsky-1.0.0.AppImage`
2. **Select a Migration** - Choose from available migrations (e.g., Google Photos → Immich)
3. **Export Data** - Follow the guide to export your data (e.g., from takeout.google.com)
4. **Upload Files** - Drag and drop your exported ZIP files into the app
5. **Import** - Watch the progress as your data is imported to local services
6. **Set Up Remote Access** - Optionally configure Tailscale for remote access
7. **Preview & Commit** - Review your migrated data and commit the changes

## Available Migrations

| Migration | Source | Target | Status |
|-----------|--------|--------|--------|
| Google Photos → Immich | Google Photos | Immich | ✅ Complete |
| Google Drive → Nextcloud | Google Drive | Nextcloud | 🚧 Planned |
| iCloud Photos → Immich | iCloud | Immich | 🚧 Planned |

## Services

### Immich (Photos)
- Photo management with albums, faces, and search
- Runs on `http://localhost:2283`
- Data stored in `~/.clearsky/immich`

### Tailscale (Remote Access)
- Secure VPN for accessing your services from anywhere
- Runs as a containerized client
- Configuration stored in `~/.clearsky/tailscale`

## Development

### Prerequisites

- Nix package manager (for reproducible builds) - optional
- Node.js 18+ (for development)
- Podman (for running containers)

### Setup

```bash
# Enter development shell (if using Nix)
nix develop

# Install npm dependencies
cd app
npm install

# Run in development mode
npm start
```

### Building AppImage with Nix

```bash
# Build using Nix (bundles all dependencies)
nix build

# The AppImage will be at ./result/Clearsky-1.0.0.AppImage
```

### Building AppImage without Nix

```bash
cd app
npm install
npm run build
```

### Adding a New Migration

See [migrations/HOWTO.md](migrations/HOWTO.md) for detailed instructions on creating new migrations.

Quick start:

```bash
# Create migration directory
mkdir -p migrations/my-migration

# Create flake.nix and migrate.nix
# Use harnesses: download, extract, import-immich

# Add to migrations/registry.nix
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

### Migrations not loading

If you're running without Nix, migrations will use a fallback mode. For full migration support, build with Nix:

```bash
nix build
```

## Contributing

Contributions are welcome! Especially new migrations!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contributing Migrations

See [migrations/HOWTO.md](migrations/HOWTO.md) for the complete guide on creating and contributing migrations.

## Documentation

- [HOWTO.md](migrations/HOWTO.md) - How to contribute new migrations
- [HARNESSES.md](migrations/HARNESSES.md) - Documentation for migration harnesses
- [EXAMPLES.md](migrations/EXAMPLES.md) - Example migration implementations
- [INSTALLATION.md](INSTALLATION.md) - Detailed installation guide
- [BUILDING.md](BUILDING.md) - Build instructions

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
