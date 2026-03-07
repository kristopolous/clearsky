---
name: new-migration
description: Guide for creating new Clearsky migrations using Nix flakes. Use when adding support for migrating data from a new cloud service to a self-hosted alternative.
---

# Clearsky Migration Creator

## Overview

This skill teaches you how to create new migrations for Clearsky - a desktop application that helps non-technical users migrate data from cloud services to self-hosted alternatives using Nix flakes.

Each migration is a self-contained Nix flake that:
- Declares source and target services
- Uses reusable harnesses (download, extract, import)
- Can be tested independently
- Works across Linux, macOS, and Windows

---

# Process

## Phase 1: Plan Your Migration

### 1.1 Identify Source and Target

**Source Service:** What cloud service are users migrating FROM?
- Google Photos, Substack, Medium, iCloud, Dropbox, etc.

**Target Service:** What self-hosted alternative are users migrating TO?
- Immich (photos), Ghost (blogging), Nextcloud (files), Home Assistant (automation), etc.

### 1.2 Determine Migration Type

**Setup Migration** (e.g., `ghost-setup`, `nextcloud-setup`):
- Sets up a new self-hosted service from scratch
- No source data - just creates the service
- Uses `setup-*` harness

**Import Migration** (e.g., `substack-to-ghost`, `medium-to-ghost`):
- Migrates existing data from source to target
- Requires export from source service
- Uses `import-*` harness

**Full Migration** (e.g., `google-photos-to-immich`):
- Downloads data from source API OR accepts manual export
- Imports to target service
- Uses both `download` and `import-*` harnesses

### 1.3 Research Export Options

**For Source Service:**
- Does it have an API for programmatic access?
- Does it support data export (Takeout, CSV, ZIP)?
- What format is the export (CSV, JSON, ZIP, HTML)?

**Examples:**
- Google Photos: API key + Google Photos Library API, OR Google Takeout ZIP
- Substack: CSV export from Settings → Advanced
- Medium: ZIP export from Settings → Download your information

---

## Phase 2: Create Migration Structure

### 2.1 Create Directory Structure

```bash
cd /path/to/clearsky/migrations
mkdir -p source-to-target
```

**Naming convention:**
- Setup: `servicename-setup` (e.g., `ghost-setup`)
- Migration: `source-to-target` (e.g., `substack-to-ghost`)

### 2.2 Create flake.nix

```nix
{
  description = "Source to Target migration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      harnesses = pkgs.callPackage ../harnesses {};
    in {
      packages.${system}.default = pkgs.callPackage ./migrate.nix {
        inherit (harnesses) download extract import-target;
      };

      packages.${system}.source-to-target = {
        name = "Source to Target";
        source = "source-service";
        target = "target-service";
        description = "Migrate Source exports to Target";
        version = "1.0.0";

        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) download extract import-target;
        };
      };
    };
}
```

### 2.3 Create migrate.nix

**For Setup Migration:**

```nix
{ pkgs, setup-target }:

pkgs.stdenv.mkDerivation {
  name = "target-setup";
  version = "1.0.0";

  buildInputs = [ pkgs.curl ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    echo "Setting up Target..."
    
    HOST="${TARGET_HOST:-http://localhost:PORT}"
    
    ${setup-target}/bin/setup-target --host "$HOST"

    echo "Target setup complete!"
    echo "Access at: $HOST"
    EOF

    chmod +x $out/bin/migrate
  '';
}
```

**For Import Migration:**

```nix
{ pkgs, download, extract, import-target }:

pkgs.stdenv.mkDerivation {
  name = "source-to-target";
  version = "1.0.0";

  buildInputs = [ pkgs.curl pkgs.unzip ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    echo "Starting Source to Target migration..."

    ZIP_FILE="${SOURCE_ZIP:-}"
    TMPDIR=$(mktemp -d)
    EXTRACT_DIR="$TMPDIR/extracted"
    mkdir -p "$EXTRACT_DIR"

    # Check for ZIP file
    if [ -n "$ZIP_FILE" ]; then
      echo "Using provided ZIP file: $ZIP_FILE"
      cp "$ZIP_FILE" "$TMPDIR/export.zip"
    else
      echo "No ZIP file provided."
      echo "Export from Source and run with SOURCE_ZIP=/path/to/export.zip"
      exit 1
    fi

    # Extract
    echo "Extracting export..."
    ${extract}/bin/extract \
      --input "$TMPDIR/export.zip" \
      --output "$EXTRACT_DIR"

    # Import
    echo "Importing to Target..."
    ${import-target}/bin/import-target \
      --input "$EXTRACT_DIR"

    rm -rf "$TMPDIR"
    echo "Migration complete!"
    EOF

    chmod +x $out/bin/migrate
  '';
}
```

---

## Phase 3: Create or Update Harnesses

### 3.1 Check Existing Harnesses

In `migrations/harnesses/`:
- `download.nix` - Download from URL
- `extract.nix` - Extract ZIP/TAR
- `import-immich.nix` - Import to Immich
- `import-etherpad.nix` - Import to Etherpad
- `import-ghost.nix` - Import to Ghost
- `setup-nextcloud.nix` - Setup Nextcloud
- `setup-ghost.nix` - Setup Ghost
- `setup-homeassistant.nix` - Setup Home Assistant
- `run-container.nix` - Universal container runner

### 3.2 Create New Harness (If Needed)

**For New Import:**

```nix
{ pkgs, run-container }:

pkgs.writeShellScriptBin "import-target" ''
  set -e

  INPUT=""
  HOST="http://localhost:PORT"

  while [ $# -gt 0 ]; do
    case "$1" in
      --input) INPUT="$2"; shift 2 ;;
      --host) HOST="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  if [ -z "$INPUT" ]; then
    echo "Usage: import-target --input DIR [--host URL]"
    exit 1
  fi

  # Start target container if needed
  ${run-container}/bin/run-container \
    --name target \
    --image docker.io/library/target:latest \
    --port PORT \
    --volume "$HOME/.clearsky/target:/data"

  # Wait for target to start
  for i in {1..30}; do
    if curl -s "$HOST" > /dev/null; then
      echo "Target started"
      break
    fi
    sleep 1
  done

  # Import data
  echo "Importing from $INPUT to Target..."
  # Add import logic here

  echo "Import complete!"
''
```

**For New Setup:**

```nix
{ pkgs, run-container }:

pkgs.writeShellScriptBin "setup-target" ''
  set -e

  HOST="http://localhost:PORT"
  DATA_DIR="$HOME/.clearsky/target"

  while [ $# -gt 0 ]; do
    case "$1" in
      --host) HOST="$2"; shift 2 ;;
      --data-dir) DATA_DIR="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  mkdir -p "$DATA_DIR"

  echo "Setting up Target..."

  # Check if already running
  if curl -s "$HOST" > /dev/null; then
    echo "Target already running at $HOST"
    exit 0
  fi

  # Start container
  ${run-container}/bin/run-container \
    --name target \
    --image docker.io/library/target:latest \
    --port PORT \
    --volume "$DATA_DIR:/data"

  # Wait for start
  echo "Waiting for Target to start..."
  for i in {1..60}; do
    if curl -s "$HOST" > /dev/null; then
      echo "Target started!"
      break
    fi
    sleep 1
  done

  echo ""
  echo "Target is running at $HOST"
''
```

### 3.3 Register Harness

Update `migrations/harnesses/default.nix`:

```nix
{ pkgs }:

let
  run-container = pkgs.callPackage ./run-container.nix {};
in {
  # ... existing harnesses ...
  import-target = pkgs.callPackage ./import-target.nix { inherit run-container; };
  setup-target = pkgs.callPackage ./setup-target.nix { inherit run-container; };
}
```

---

## Phase 4: Register Migration

### 4.1 Update Registry

Edit `migrations/registry.nix`:

```nix
{ pkgs }:

let
  harnesses = pkgs.callPackage ./harnesses {};

  migrations = {
    # ... existing migrations ...
    
    source-to-target = pkgs.callPackage ./source-to-target/migrate.nix {
      inherit (harnesses) download extract import-target;
    };
  };
in {
  getMigrations = migrations;
  getMigrationNames = builtins.attrNames migrations;
}
```

---

## Phase 5: Update UI

### 5.1 Add to Upload Step Configuration

Edit `app/index.html`, find `configureUploadStep()`:

```javascript
const migration = {
  // ... existing migrations ...
  'source-to-target': { type: 'upload', title: 'Migrate Source to Target', showApi: false },
};
```

### 5.2 Add to Preview URLs

```javascript
const serviceUrls = {
  // ... existing URLs ...
  'source-to-target': 'http://localhost:PORT',
};
```

### 5.3 Add to Tailscale Instructions

In the Tailscale step HTML, add:
```html
<li><strong>Target:</strong> http://[TAILSCALE_IP]:PORT</li>
```

---

## Phase 6: Test

### 6.1 Validate Migration

```bash
cd /path/to/clearsky
node clearsky-cli.js validate source-to-target
```

### 6.2 Test with CLI

```bash
# For setup migration
node clearsky-cli.js run target-setup

# For import migration
node clearsky-cli.js run source-to-target --zip /path/to/export.zip
```

### 6.3 Test in AppImage

```bash
# Build AppImage
cd app && npm run build

# Run and test migration through UI
./dist/Clearsky-1.0.0.AppImage
```

---

# Reference

## Harness Patterns

**Download Harness:**
```nix
pkgs.writeShellScriptBin "download" ''
  # Downloads from URL to directory
  # Arguments: --from URL --to DIR --format zip
''
```

**Extract Harness:**
```nix
pkgs.writeShellScriptBin "extract" ''
  # Extracts archives
  # Arguments: --input FILE --output DIR --format zip
''
```

**Import Harness:**
```nix
{ pkgs, run-container }:
pkgs.writeShellScriptBin "import-service" ''
  # Starts service container
  # Imports data from directory
  # Arguments: --input DIR --host URL
''
```

**Setup Harness:**
```nix
{ pkgs, run-container }:
pkgs.writeShellScriptBin "setup-service" ''
  # Starts service container
  # Configures initial setup
  # Arguments: --host URL --data-dir DIR
''
```

## Container Runtime

All harnesses use `run-container.nix` which auto-detects:
1. **nix-containers** (preferred on NixOS)
2. **Podman** (Linux default)
3. **Docker** (fallback, macOS/Windows)

## Environment Variables

Migrations support these environment variables:
- `GOOGLE_PHOTOS_API_KEY` - API key for Google Photos
- `GOOGLE_PHOTOS_ZIP` - Path to Google Takeout ZIP
- `SUBSTACK_ZIP` - Path to Substack export
- `MEDIUM_ZIP` - Path to Medium export
- `TARGET_HOST` - Custom host for target service
- `TARGET_DATA_DIR` - Custom data directory

## File Naming

- **Migration directories:** `source-to-target` or `service-setup`
- **flake.nix:** Always `flake.nix`
- **Migration script:** Always `migrate.nix`
- **Harness files:** `setup-service.nix`, `import-service.nix`

---

# Examples

## Example 1: iCloud Photos to Immich

```bash
mkdir -p migrations/icloud-photos-to-immich
# Create flake.nix and migrate.nix
# Use download + import-immich harnesses
```

## Example 2: Dropbox to Nextcloud

```bash
mkdir -p migrations/dropbox-to-nextcloud
# Create flake.nix and migrate.nix
# Use download + import harness
```

## Example 3: WordPress to Ghost

```bash
mkdir -p migrations/wordpress-to-ghost
# Create flake.nix and migrate.nix
# Use download + import-ghost harnesses
```

---

# Guidelines

## DO

- ✅ Use existing harnesses when possible
- ✅ Keep migrations focused on one source→target pair
- ✅ Support both API and manual export when feasible
- ✅ Provide clear error messages
- ✅ Clean up temporary files
- ✅ Test with CLI before UI integration

## DON'T

- ❌ Delete or modify source data
- ❌ Assume container runtime (use run-container)
- ❌ Hardcode paths (use environment variables)
- ❌ Skip error handling
- ❌ Forget to update registry.nix

---

# Troubleshooting

## "Nix is not installed"

Install Nix: `curl --proto '=https' --tlsv1.2 -sSf -L https://install.nixos.sh | sh`

## "Harness not found"

Check harness is registered in `harnesses/default.nix`

## "Migration not found"

Check migration is registered in `registry.nix`

## Container won't start

- Check container runtime: `which podman docker`
- Check port availability: `lsof -i :PORT`
- Check logs: `docker logs clearsky-service`
