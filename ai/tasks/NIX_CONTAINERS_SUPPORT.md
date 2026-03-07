# nix-containers Support

## Overview

Clearsky now automatically detects and uses the best available container runtime on your system:

1. **nix-containers** (preferred on NixOS/Nix-based systems)
2. **Podman** (fallback)
3. **Docker** (fallback)

## Container Runtime Detection

The new `run-container` harness automatically detects what's available:

```bash
# Detection order
1. nix-container-run  → Use nix-containers
2. podman             → Use Podman
3. docker             → Use Docker
```

## Benefits of nix-containers

On NixOS and Nix-based systems, `nix-containers` provides:

- **Declarative configuration** - Containers defined as Nix derivations
- **Reproducibility** - Same container config = same result
- **Integration with Nix** - Containers managed alongside system packages
- **Rollback support** - Revert to previous container state via Nix generations

## Updated Harnesses

All container-running harnesses now use the `run-container` harness:

| Harness | Uses run-container |
|---------|-------------------|
| `setup-nextcloud` | ✅ |
| `setup-owncloud` | ✅ |
| `setup-homeassistant` | ✅ |
| `import-immich` | ✅ |
| `import-etherpad` | ✅ |

## How It Works

### run-container.nix

```nix
{ pkgs }:

pkgs.writeShellScriptBin "run-container" ''
  # Detect container runtime
  if command -v nix-container-run &> /dev/null; then
    RUNTIME="nix-containers"
  elif command -v podman &> /dev/null; then
    RUNTIME="podman"
  elif command -v docker &> /dev/null; then
    RUNTIME="docker"
  else
    echo "Error: No container runtime found"
    exit 1
  fi

  # Build and run command based on runtime
  case "$RUNTIME" in
    nix-containers)
      nix-container-run --name clearsky-$NAME --image $IMAGE ...
      ;;
    podman|docker)
      $RUNTIME run -d --rm --name clearsky-$NAME ...
      ;;
  esac
''
```

### Usage in setup-nextcloud.nix

```nix
{ pkgs, run-container }:

pkgs.writeShellScriptBin "setup-nextcloud" ''
  # Start Nextcloud using run-container harness
  ${run-container}/bin/run-container \
    --name nextcloud \
    --image docker.io/library/nextcloud:latest \
    --port "8080" \
    --volume "$DATA_DIR:/var/www/html" \
    --env "NEXTCLOUD_ADMIN_USER=admin" \
    --env "NEXTCLOUD_ADMIN_PASSWORD=admin123"
''
```

## Installing nix-containers

### On NixOS

Add to your `configuration.nix`:

```nix
{
  virtualisation.nix-containers.enable = true;
}
```

Or install for user:

```bash
nix-env -iA nixos.nix-containers
```

### On non-NixOS Linux

```bash
nix profile install nixpkgs#nix-containers
```

### Verify Installation

```bash
nix-container-run --version
```

## Runtime Comparison

| Feature | nix-containers | Podman | Docker |
|---------|---------------|--------|--------|
| Rootless | ✅ | ✅ | ❌ (requires daemon) |
| Declarative | ✅ | ❌ | ❌ |
| Nix integration | ✅ | ❌ | ❌ |
| Rollback support | ✅ | ❌ | ❌ |
| Systemd integration | ✅ | ✅ | ❌ |
| Availability | Nix systems | Most Linux | Everywhere |

## Example: Setting Up Nextcloud

### With nix-containers

```bash
# Clearsky detects nix-container-run
# Runs: nix-container-run --name clearsky-nextcloud \
#   --image docker.io/library/nextcloud:latest \
#   --port 8080:8080 \
#   --volume ~/.clearsky/nextcloud:/var/www/html

# Container is managed as a Nix derivation
# Can be rolled back via Nix generations
```

### With Podman

```bash
# Clearsky detects podman
# Runs: podman run -d --rm --name clearsky-nextcloud \
#   -p 8080:8080 \
#   -v ~/.clearsky/nextcloud:/var/www/html \
#   -e NEXTCLOUD_ADMIN_USER=admin \
#   -e NEXTCLOUD_ADMIN_PASSWORD=admin123 \
#   docker.io/library/nextcloud:latest
```

## Files Changed

| File | Change |
|------|--------|
| `migrations/harnesses/run-container.nix` | Created - runtime detection and abstraction |
| `migrations/harnesses/setup-nextcloud.nix` | Updated to use run-container |
| `migrations/harnesses/setup-owncloud.nix` | Updated to use run-container |
| `migrations/harnesses/setup-homeassistant.nix` | Updated to use run-container |
| `migrations/harnesses/import-immich.nix` | Updated to use run-container |
| `migrations/harnesses/import-etherpad.nix` | Updated to use run-container |
| `migrations/harnesses/default.nix` | Updated to export run-container |
| All migration `migrate.nix` files | Updated dependencies |

## AppImage

Rebuilt successfully at:
```
/home/chris/code/clearsky/app/dist/Clearsky-1.0.0.AppImage
```

## Future Improvements

1. **NixOS module** - Provide a NixOS module for system-wide Clearsky integration
2. **Container configs as Nix** - Allow users to define container configs in Nix
3. **Automatic nix-containers install** - Offer to install nix-containers if missing on NixOS
4. **Container updates** - Notify when container images have updates available
