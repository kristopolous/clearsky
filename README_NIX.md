# Clearsky: No More Clouds

## NixOS Hackathon Implementation

This is a **true Nix-based AppImage** that bundles all dependencies including Podman, immich-go, and tailscale.

### Build the AppImage with Nix

```bash
nix build
```

The AppImage will be at `./result/bin/clearsky` (or similar path).

### What Makes This Nix-Based

1. **Reproducible Builds** - Same dependencies every time via `flake.nix`
2. **All Dependencies Bundled** - Podman, immich-go, tailscale are in the AppImage
3. **Declarative** - `appimage.nix` defines exactly what goes in the AppImage
4. **No System Dependencies** - Works on any Linux with AppImage support

### Nix Files

| File | Purpose |
|------|---------|
| `flake.nix` | Entry point, defines inputs and outputs |
| `appimage.nix` | Nix expression that wraps AppImage with all deps |
| `default.nix` | Alternative entry point for non-flake Nix |

### Build with Nix

```bash
# Using flakes
nix build

# Using default.nix
nix-build

# Enter dev shell
nix-shell
```

### Dependencies in Nix Build

The Nix expression bundles:
- **Node.js** - Runtime for Electron
- **Electron** - Desktop framework
- **Podman** - Container runtime
- **immich-go** - Photo import tool
- **tailscale** - Remote access client

### Running the App

```bash
# The AppImage is self-contained
./result/bin/clearsky

# Or copy it anywhere and run
cp ./result/bin/clearsky ~/Downloads/
~/Downloads/clearsky
```

### What Runs Inside

1. **Electron app** - GUI migration wizard
2. **Podman** - Creates containers for Immich/Tailscale
3. **immich-go** - Imports photos to Immich
4. **tailscale** - Sets up remote access

### Nix Advantages for This Project

- ✅ **Reproducibility** - Same build everywhere
- ✅ **Bundling** - No user installation needed
- ✅ **Atomic updates** - Replace whole AppImage
- ✅ **Sandboxing** - Builds in isolation
- ✅ **Declarative** - Clear dependency list