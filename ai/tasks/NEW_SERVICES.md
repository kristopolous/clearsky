# New Services Added: Nextcloud, ownCloud, Home Assistant

## Summary

Three new setup migrations have been added to Clearsky, allowing users to set up self-hosted services with a single click:

| Service | Port | Description |
|---------|------|-------------|
| Nextcloud | 8080 | File storage, calendar, contacts, collaboration |
| ownCloud | 8081 | File sharing and collaboration platform |
| Home Assistant | 8123 | Home automation and smart device control |

## What Was Added

### 1. Migration Harnesses

**New files in `migrations/harnesses/`:**

- **setup-nextcloud.nix** - Starts Nextcloud container with admin credentials
- **setup-owncloud.nix** - Starts ownCloud container with admin credentials  
- **setup-homeassistant.nix** - Starts Home Assistant container with config volume

**Updated:**
- `harnesses/default.nix` - Registered all three new harnesses

### 2. Migration Packages

**New directories:**

```
migrations/
├── nextcloud-setup/
│   ├── flake.nix          # Migration metadata
│   └── migrate.nix        # Setup script
├── owncloud-setup/
│   ├── flake.nix
│   └── migrate.nix
└── homeassistant-setup/
    ├── flake.nix
    └── migrate.nix
```

**Updated:**
- `migrations/registry.nix` - Added all three new migrations

### 3. UI Updates

**Updated `app/index.html`:**

- **Migration selector** - Now shows all 5 migrations
- **Guide step** - Shows service-specific setup information
- **Upload step** - Dynamic based on migration type:
  - Upload migrations (Google Photos/Docs): Show file upload
  - Setup migrations (Nextcloud/ownCloud/HA): Show confirmation
- **Preview step** - Opens correct service URL
- **Complete step** - Dashboard button opens correct URL

## User Experience

### Setting Up Nextcloud

1. **Select migration**: "Nextcloud Setup"
2. **Read description**: Shows features (file storage, calendar, etc.)
3. **Click Continue** → Upload step
4. **See confirmation**: "This will start Nextcloud on http://localhost:8080"
5. **Click "🚀 Start Setup"**
6. **Watch progress**: Container starts, waits for service
7. **Preview**: Opens Nextcloud at localhost:8080
8. **Login**: admin / admin123 (change after login!)

### Setting Up ownCloud

Same flow as Nextcloud, but:
- Runs on port 8081
- Different container image

### Setting Up Home Assistant

Same flow, but:
- Runs on port 8123
- Takes longer to start (up to 2 minutes)
- First-time setup requires creating user account

## Service Details

### Nextcloud

**Container:** `nextcloud:latest`
**Port:** 8080
**Data:** `~/.clearsky/nextcloud`
**Default credentials:** admin / admin123

**Features:**
- File storage and sharing
- Calendar and contacts sync
- Document collaboration (Collabora/OnlyOffice)
- Video calls and chat
- App store with 100+ apps

### ownCloud

**Container:** `owncloud/server:latest`
**Port:** 8081
**Data:** `~/.clearsky/owncloud`
**Default credentials:** admin / admin123

**Features:**
- File storage and sharing
- Calendar and contacts sync
- Document collaboration
- Enterprise-grade security
- Marketplace for extensions

### Home Assistant

**Container:** `ghcr.io/home-assistant/home-assistant:stable`
**Port:** 8123
**Data:** `~/.clearsky/homeassistant`
**Auth:** Create account on first run

**Features:**
- Home automation platform
- 1000+ device integrations
- Local control (no cloud required)
- Powerful automation scripting
- Voice control support

## Code Structure

### Harness Pattern

Each setup harness follows the same pattern:

```nix
{ pkgs }:

pkgs.writeShellScriptBin "setup-SERVICE" ''
  set -e

  # Parse command-line arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --host) HOST="$2"; shift 2 ;;
      --data-dir) DATA_DIR="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  # Check if already running
  if curl -s "$HOST" > /dev/null; then
    echo "Already running"
    exit 0
  fi

  # Start container
  podman run -d --name clearsky-SERVICE \
    -p PORT:PORT \
    -v "$DATA_DIR:/config" \
    IMAGE:TAG

  # Wait for service
  for i in {1..60}; do
    if curl -s "$HOST" > /dev/null; then
      echo "Started!"
      break
    fi
    sleep 1
  done
''
```

### Migration Pattern

Each migration wraps its harness:

```nix
{ pkgs, setup-SERVICE }:

pkgs.stdenv.mkDerivation {
  name = "SERVICE-setup";
  
  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    ${setup-SERVICE}/bin/setup-SERVICE
    EOF
    chmod +x $out/bin/migrate
  '';
}
```

## Testing

To test the new migrations:

```bash
# Run in development mode
cd app
npm start

# Select a setup migration from dropdown
# Click Continue → Start Setup
# Watch progress
# Open service URL
```

## Security Notes

- Default passwords are provided for Nextcloud/ownCloud
- Users should change passwords immediately
- Containers run as rootless (Podman default)
- Data stored in user's home directory (`~/.clearsky/`)

## Future Improvements

1. **Custom credentials** - Let users set admin password before setup
2. **Custom ports** - Allow port configuration
3. **HTTPS setup** - Auto-configure reverse proxy with Let's Encrypt
4. **Backup/restore** - Add backup functionality for each service
5. **Service management** - Start/stop/restart from UI
6. **More services** - Add Radicale (calendar), Vaultwarden (passwords), etc.

## Files Changed

| File | Change |
|------|--------|
| `migrations/harnesses/setup-nextcloud.nix` | Created |
| `migrations/harnesses/setup-owncloud.nix` | Created |
| `migrations/harnesses/setup-homeassistant.nix` | Created |
| `migrations/harnesses/default.nix` | Updated |
| `migrations/nextcloud-setup/` | Created |
| `migrations/owncloud-setup/` | Created |
| `migrations/homeassistant-setup/` | Created |
| `migrations/registry.nix` | Updated |
| `app/index.html` | Updated |

## AppImage

Rebuilt successfully at:
```
/home/chris/code/clearsky/app/dist/Clearsky-1.0.0.AppImage
```
