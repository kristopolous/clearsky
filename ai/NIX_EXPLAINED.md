# Clearsky: No More Clouds

## Nix-Powered AppImage Build

This project uses **Nix** to build a reproducible AppImage with all dependencies bundled.

### How It Uses Nix

1. **flake.nix** - Entry point that:
   - Imports nixpkgs for x86_64-linux
   - Calls `appimage.nix` to build the AppImage
   - Provides a devShell with all build/runtime dependencies

2. **appimage.nix** - Builds the AppImage using:
   - `appimageTools.wrapAppImage` - Wraps Electron app + dependencies into AppImage
   - Bundles: Node.js, Electron, Podman, immich-go, tailscale
   - Creates launcher script that sets up environment

3. **devShell** - Development environment with:
   - All dependencies available in PATH
   - ShellHook to guide usage

### Build the AppImage

```bash
# Using Nix flakes
nix build

# The AppImage will be at ./result/bin/clearsky
```

### Run in Dev Mode

```bash
# Enter dev shell with all dependencies
nix-shell

# Install npm dependencies
npm install

# Run the app
npm start
```

### What Nix Actually Does Here

- **Reproducible builds** - Same dependencies every time
- **Dependency isolation** - No conflict with system packages
- **Bundling** - All needed binaries wrapped into single AppImage
- **Atomic rollbacks** - Can switch between versions cleanly
- **No root required** - Builds in sandboxed environment

### Dependencies in Nix

| Tool | Purpose | Nix Package |
|------|---------|-------------|
| Node.js | Electron runtime | `nodejs` |
| Electron | Desktop framework | `electron` |
| Podman | Container runtime | `podman` |
| immich-go | Photo import tool | `immich-go` |
| tailscale | Remote access | `tailscale` |

### AppImage Contents

The generated AppImage contains:
- Electron app (main.js, index.html, package.json)
- Node.js runtime
- Podman client
- Immich-go CLI
- Tailscale CLI
- All shared libraries

### Why This Is Better Than Just npm

- ✅ Single file distribution (AppImage)
- ✅ No system dependencies needed on target machine
- ✅ Reproducible across all Linux systems
- ✅ Atomic updates/rollbacks via Nix
- ✅ Sandboxed builds (no contamination)
- ✅ Same environment for dev and prod