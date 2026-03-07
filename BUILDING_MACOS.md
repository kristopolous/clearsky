# Building Clearsky on macOS

This guide explains how to build and run Clearsky on macOS (Darwin).

## Prerequisites

### Required

1. **Node.js 18+**
   ```bash
   brew install node@18
   ```

2. **Container Runtime** (choose one)
   
   **OrbStack** (Recommended - Lightweight, fast):
   ```bash
   brew install orbstack
   ```
   
   **Docker Desktop** (Most common):
   - Download from [docker.com](https://www.docker.com/products/docker-desktop/)
   
   **Podman** (Open source):
   ```bash
   brew install podman
   podman machine init
   podman machine start
   ```

### Optional (for Nix builds)

3. **Nix** (for reproducible builds)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
   ```

## Quick Start (npm)

The easiest way to run Clearsky on macOS:

```bash
# Clone the repository
git clone https://github.com/clearsky/clearsky.git
cd clearsky/app

# Install dependencies
npm install

# Run in development mode
npm start

# Build macOS app
npm run build:mac
```

The built app will be in `dist/` directory.

## Building with Nix

### Apple Silicon (M1/M2/M3)

```bash
cd /path/to/clearsky
nix build .#packages.aarch64-darwin.default
```

### Intel Mac

```bash
cd /path/to/clearsky
nix build .#packages.x86_64-darwin.default
```

The output will be a `.app` bundle or `.dmg` installer.

## Container Runtime on macOS

### How It Works

On macOS, containers run in a lightweight Linux VM:

```
┌─────────────────────────────────────┐
│  macOS                              │
│  ┌───────────────────────────────┐  │
│  │  VM (Linux)                   │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │  Container (Immich,     │  │  │
│  │  │  Nextcloud, etc.)       │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Runtime Detection

Clearsky automatically detects your container runtime:

1. **OrbStack** - Fastest, lightest (recommended)
2. **Docker Desktop** - Most common
3. **Podman Machine** - Open source

No configuration needed - it just works!

### Volume Paths

On macOS, home directories are `/Users/username/` instead of `/home/username/`.

Clearsky handles this automatically:
- Data stored in `~/.clearsky/` (e.g., `/Users/you/.clearsky/`)
- Volume mounts work transparently

## Tailscale on macOS

### Installation

**Option 1: App Store (Recommended)**
```bash
# Open App Store and search for "Tailscale"
# Or direct link: https://apps.apple.com/app/tailscale/id1470766631
```

**Option 2: Direct Download**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

### Setup

1. Install Tailscale on your Mac
2. Sign in with your account
3. Install Tailscale on your phone
4. Sign in with the same account
5. Your Mac appears in the device list
6. Access services via Tailscale IP

## Available Migrations on macOS

All migrations work on macOS:

| Migration | Status |
|-----------|--------|
| Google Photos → Immich | ✅ |
| Google Docs → Etherpad | ✅ |
| Substack → Ghost | ✅ |
| Medium → Ghost | ✅ |
| Nextcloud Setup | ✅ |
| ownCloud Setup | ✅ |
| Home Assistant Setup | ✅ |
| Ghost Setup | ✅ |

## Troubleshooting

### "No container runtime found"

Install a container runtime:

```bash
# OrbStack (recommended)
brew install orbstack

# Or Docker Desktop
# Download from docker.com

# Or Podman
brew install podman
podman machine init
podman machine start
```

### "Permission denied" on volume mounts

This is handled automatically by Docker Desktop/OrbStack. If you see this error:

1. Open Docker Desktop settings
2. Go to "Resources" → "File Sharing"
3. Add `~/.clearsky` to the list
4. Restart Docker

### App won't open (Gatekeeper)

macOS may block unsigned apps:

```bash
# Option 1: Right-click → Open
# Option 2: System Settings → Privacy & Security → Allow
# Option 3: (Advanced) xattr -d com.apple.quarantine /Applications/Clearsky.app
```

### Container won't start

Check if your container runtime is running:

```bash
# OrbStack
orbstack status

# Docker Desktop
# Check the Docker Desktop app

# Podman
podman machine list
```

## Performance Tips

1. **Use OrbStack** - Faster startup, less memory than Docker Desktop
2. **Close unused containers** - `docker ps` to see what's running
3. **Limit concurrent migrations** - One at a time for best performance
4. **SSD space** - Ensure you have 5GB+ free for containers

## Architecture Differences

### Linux vs macOS

| Feature | Linux | macOS |
|---------|-------|-------|
| Container runtime | Podman (native) | Docker/OrbStack (VM) |
| Volume paths | `/home/user/` | `/Users/user/` |
| Data directory | `~/.clearsky/` | `~/.clearsky/` |
| Tailscale | CLI/App | App Store/CLI |
| Build output | AppImage | .app/.dmg |

## Distribution

### For Developers

```bash
# Build universal binary (Intel + Apple Silicon)
cd app
npm run build:mac

# Output: dist/Clearsky-1.0.0-universal.dmg
```

### For Users

Download the `.dmg` file:
1. Open the DMG
2. Drag Clearsky to Applications
3. Launch from Applications folder

## Next Steps

After installation:
1. [Usage Guide](QUICKSTART.md) - Get started with migrations
2. [CLI Documentation](CLI.md) - Command-line usage
3. [Testing](TESTING.md) - Run automated tests

## Support

- **Issues**: [GitHub Issues](https://github.com/clearsky/clearsky/issues)
- **Discussions**: [GitHub Discussions](https://github.com/clearsky/clearsky/discussions)

---

**Clearsky**: Self-hosting for everyone. Not just sysadmins. 🌤️
