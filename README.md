<p align="center">
  <img width=560 src=https://github.com/user-attachments/assets/50166458-17e9-4c9c-b058-505b1ab4e33a>
<br/>
</p>

# Tossing those clouds away

**Clearsky** is a desktop application that makes self-hosting accessible to **everyone**—not just system administrators and power users. It guides non-technical users through migrating their data from cloud services (Google Photos, Google Drive, iCloud) to self-hosted, privacy-focused alternatives.

## Why This Exists

Nix is incredibly powerful, but it has a steep learning curve. Clearsky demonstrates that **Nix can power user-friendly applications** that hide all complexity behind a simple graphical interface. No terminal commands. No configuration files. No "works on my machine" problems.

**This is what happens when you apply Nix's reproducibility and modularity to real-world problems:** families can reclaim their photos from Google, small businesses can host their own documents, and anyone can run their own services—without learning a new operating system.

## Features

- 🎯 **Simple Migration Wizard** - Step-by-step guided process, no technical knowledge required
- 🧩 **Modular Migration Framework** - Extensible architecture built on Nix flakes
- 🤖 **AI-Powered Migration Creator** - Claude Skills for agentic migration development
- 📸 **Google Photos → Immich** - Automatic download via API or manual Takeout export
- 📁 **Google Docs → Etherpad** - Migrate documents for collaborative editing
- ✍️ **Substack/Medium → Ghost** - Migrate blogs to self-hosted Ghost
- ☁️ **One-Click Service Setup** - Nextcloud, ownCloud, Home Assistant, Ghost
- 🔐 **Privacy First** - All data stays on your machine, under your control
- 🔄 **Easy Rollback** - Undo migrations with a single click
- 🌐 **Remote Access** - Tailscale integration for secure access from anywhere
- 📦 **Self-Contained AppImage** - Everything bundled via Nix, runs on any Linux

## Architecture

<img width="2752" height="1536" alt="clearsky" src="https://github.com/user-attachments/assets/a4101fa3-a52f-4064-83ad-de586918b8c8" />

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
│   │   ├── import-immich.nix  # Import to Immich
│   │   └── setup-nextcloud.nix # Set up Nextcloud
│   ├── google-photos-to-immich/
│   │   ├── flake.nix
│   │   └── migrate.nix
│   └── registry.nix           # Migration registry
├── flake.nix                   # Main Nix flake
└── appimage.nix                # AppImage build
```

### What Makes This Different

**Traditional self-hosting:**
```
1. Install Docker/Podman
2. Find the right container image
3. Figure out volume mounts
4. Configure environment variables
5. Debug why it won't start
6. Read documentation for hours
7. Maybe it works?
```

**Clearsky:**
```
1. Double-click AppImage
2. Select "Google Photos to Immich"
3. Paste API key (or upload Takeout ZIP)
4. Click "Download My Photos Automatically"
5. Done
```

### Migration Framework

Each migration is a self-contained Nix flake that:

- Declares its source and target services
- Uses reusable harnesses (download, extract, import, setup)
- Can be tested independently
- Can be contributed by third parties

**Want to add a migration?** Create a new flake in `migrations/` and register it in `registry.nix`. See [HOWTO.md](migrations/HOWTO.md) for details.

## Prerequisites

- Linux (Ubuntu 20.04+, NixOS 24.11+, or other modern distro)
- Podman 4.0+ **OR** nix-containers (preferred on NixOS)
- 2GB free disk space

**That's it.** No Node.js, no npm, no build tools—unless you want to modify the code.

## Installation

### Option 1: Download Pre-Built AppImage (Easiest)

```bash
# Download the AppImage
wget https://github.com/clearsky/clearsky/releases/download/v1.0.0/Clearsky-1.0.0.AppImage

# Make it executable
chmod +x Clearsky-1.0.0.AppImage

# Run it
./Clearsky-1.0.0.AppImage
```

### Option 2: Build from Source with Nix (Reproducible)

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

### Migrating Google Photos to Immich

1. **Launch Clearsky** - Double-click the AppImage
2. **Select migration** - Choose "Google Photos to Immich"
3. **Get API key** (recommended):
   - Click link to Google Cloud Console
   - Enable Google Photos Library API
   - Create API Key
   - Paste key into Clearsky
   - Click "🚀 Download My Photos Automatically"
4. **Or use Takeout** (fallback):
   - Click "Use Google Takeout instead"
   - Export from takeout.google.com
   - Upload ZIP file
5. **Watch progress** - Photos download/import automatically
6. **Preview** - Open Immich to verify
7. **Set up remote access** (recommended):
   - Click "Set Up Tailscale"
   - Sign in with Google/Microsoft/GitHub
   - Install Tailscale on your phone
   - Get your Tailscale IP address
8. **Done** - Access Immich from your phone at `http://[TAILSCALE_IP]:2283`

### Setting Up Remote Access (Tailscale)

**Why you need this:** Your self-hosted services run on your home computer. To access them from your phone when you're away, you need a secure connection through your home's firewall/NAT.

**Tailscale** creates a private, encrypted network between your devices—no port forwarding required.

#### On Your Computer (running Clearsky)

1. In Clearsky, click "Set Up Tailscale"
2. A browser window opens—sign in with any account
3. Authorize the device
4. Note your Tailscale IP address (starts with `100.`)

#### On Your Phone

1. **Download Tailscale:**
   - **iOS:** [App Store](https://apps.apple.com/app/tailscale/id1475387142)
   - **Android:** [Google Play](https://play.google.com/store/apps/details?id=com.tailscale.ipn) | [F-Droid](https://f-droid.org/packages/com.tailscale.ipn/)

2. **Sign in** with the same account as on your computer

3. **Enable Tailscale** on your phone

4. **Access your services:**
   - Open your phone's browser
   - Go to `http://[YOUR_TAILSCALE_IP]:2283` for Immich
   - Or `http://[YOUR_TAILSCALE_IP]:8080` for Nextcloud, etc.

#### Optional: Native Mobile Apps

For the best experience, consider installing native apps for your self-hosted services:

**Immich (Photos):**
- **iOS:** [App Store](https://apps.apple.com/app/immich/id1613945252) | [Setup Guide](https://immich.app/docs/features/mobile-app)
- **Android:** [Google Play](https://play.google.com/store/apps/details?id=app.alextran.immich) | [F-Droid](https://f-droid.org/packages/app.alextran.immich/) | [Direct APK](https://github.com/immich-app/immich/releases)

**Nextcloud (Files):**
- **iOS:** [App Store](https://apps.apple.com/app/nextcloud/id1125420102)
- **Android:** [Google Play](https://play.google.com/store/apps/details?id=com.nextcloud.client) | [F-Droid](https://f-droid.org/packages/com.nextcloud.client/)

**Home Assistant:**
- **iOS:** [App Store](https://apps.apple.com/app/home-assistant/id1099568401)
- **Android:** [Google Play](https://play.google.com/store/apps/details?id=io.homeassistant.companion.android) | [F-Droid](https://f-droid.org/packages/io.homeassistant.companion.android.minimal/)

#### Example

If your Tailscale IP is `100.87.42.15`:
- Immich: `http://100.87.42.15:2283`
- Nextcloud: `http://100.87.42.15:8080`
- Home Assistant: `http://100.87.42.15:8123`

**Tip:** Add these URLs to your phone's home screen for app-like access!

### Available Migrations

| Migration | Type | Description |
|-----------|------|-------------|
| Google Photos → Immich | Migration | Download photos automatically via API or Takeout |
| Google Docs → Etherpad | Migration | Export docs, import for collaboration |
| Nextcloud Setup | Service | File storage, calendar, contacts, docs |
| ownCloud Setup | Service | Similar to Nextcloud, enterprise focus |
| Home Assistant Setup | Service | Home automation, 1000+ device integrations |

## Services

### Immich (Photos)
- Photo management with albums, faces, and search
- Runs on `http://localhost:2283`
- Data stored in `~/.clearsky/immich`

### Nextcloud (Files & Collaboration)
- File storage and sharing (like Google Drive)
- Calendar and contacts sync
- Document collaboration (like Google Docs)
- Runs on `http://localhost:8080`
- Data stored in `~/.clearsky/nextcloud`

### ownCloud (Files & Collaboration)
- Similar to Nextcloud
- Enterprise-grade security
- Runs on `http://localhost:8081`
- Data stored in `~/.clearsky/owncloud`

### Home Assistant (Home Automation)
- Control lights, thermostats, locks, and more
- Works with 1000+ brands and devices
- Local control - no cloud required
- Runs on `http://localhost:8123`
- Data stored in `~/.clearsky/homeassistant`

### Tailscale (Remote Access)
- Secure VPN for accessing your services from anywhere
- Runs as a containerized client
- Configuration stored in `~/.clearsky/tailscale`

## Container Runtime

Clearsky automatically detects and uses the best available container runtime:

1. **nix-containers** (preferred on NixOS/Nix-based systems)
   - Declarative configuration
   - Reproducible containers
   - Nix integration
   - Rollback support

2. **Podman** (fallback)
   - Rootless by default
   - Systemd integration
   - Widely available

3. **Docker** (last resort)
   - Universal availability

## Development

### Prerequisites

- Nix package manager (for reproducible builds) - optional
- Node.js 18+ (for development)
- Podman or nix-containers (for running containers)

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

### No container runtime found

Clearsky needs a container runtime to run services:

```bash
# Install nix-containers (preferred on NixOS)
nix profile install nixpkgs#nix-containers

# Or install Podman
sudo apt install podman  # Ubuntu/Debian
sudo dnf install podman  # Fedora
sudo pacman -S podman    # Arch
nix-env -iA nixos.podman # NixOS
```

### Port already in use

```bash
# Check what's using the port
lsof -i :8080  # or :2283, :8081, :8123

# Stop the conflicting service
podman stop clearsky-nextcloud
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

Contributions are welcome! This project exists to make self-hosting accessible to everyone.

### Ways to Contribute

1. **New migrations** - Add support for more cloud services
2. **Better UX** - Improve the wizard, error messages, documentation
3. **Testing** - Test on different Linux distributions
4. **Translations** - Make Clearsky accessible in more languages

### Getting Started

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contributing Migrations

#### Option 1: Use Claude Skills (Recommended)

The easiest way to create a new migration is to use the **new-migration** Claude Skill:

1. **Enable the skill** in Claude:
   - Copy the `skills/new-migration/` folder to your Claude skills directory
   - Or reference it when chatting with Claude

2. **Ask Claude to create a migration**:
   ```
   Use the new-migration skill to create a migration from Twitter to Ghost
   ```

3. **Claude will guide you through**:
   - Planning the migration (source, target, export format)
   - Creating the Nix flake structure
   - Using existing harnesses or creating new ones
   - Testing the migration

This agentic approach handles the Nix complexity automatically while you focus on the migration logic.

#### Option 2: Manual Creation

See [migrations/HOWTO.md](migrations/HOWTO.md) for the complete guide on creating and contributing migrations manually.

#### Migration Ideas

Looking for inspiration? Here are some requested migrations:

- **Twitter/X → Ghost** - Export tweets, import as blog posts
- **iCloud Photos → Immich** - Download from iCloud, import to Immich
- **Dropbox → Nextcloud** - Migrate files and folders
- **WordPress → Ghost** - Export WordPress XML, import to Ghost
- **Pocket → Self-hosted** - Export bookmarks to linkding or similar
- **IFTTT → Home Assistant** - Migrate applets to automations

## Documentation

### User Documentation
- [INSTALLATION.md](INSTALLATION.md) - Installation guide
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [CLI.md](CLI.md) - Command-line interface usage
- [TESTING.md](TESTING.md) - Running tests

### Developer Documentation
- [code-walkthrough.md](code-walkthrough.md) - How Nix enables data sovereignty
- [BUILDING.md](BUILDING.md) - Build instructions

### Migration Documentation
- [skills/new-migration/SKILL.md](skills/new-migration/SKILL.md) - **Agentic migration creator (Claude Skill)**
- [migrations/registry.nix](migrations/registry.nix) - Current migration registry

### Skills
- [skills/](skills/) - Claude Skills for agentic workflows
  - [new-migration](skills/new-migration/) - Create new migrations with AI assistance

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Electron](https://www.electronjs.org/)
- Containerized with [Podman](https://podman.io/) and [nix-containers](https://github.com/nix-community/nix-containers)
- Photo management with [Immich](https://immich.app/)
- File storage with [Nextcloud](https://nextcloud.com/) and [ownCloud](https://owncloud.com/)
- Home automation with [Home Assistant](https://www.home-assistant.io/)
- Remote access with [Tailscale](https://tailscale.com/)
- Reproducible builds with [Nix](https://nixos.org/)

## Contact

- GitHub: [https://github.com/clearsky/clearsky](https://github.com/clearsky/clearsky)
- Issues: [https://github.com/clearsky/clearsky/issues](https://github.com/clearsky/clearsky/issues)

---

**Clearsky**: Self-hosting for everyone. Not just sysadmins. 🌤️
