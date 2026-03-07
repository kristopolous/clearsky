# Clearsky: No More Clouds

## NixOS Hackathon Implementation

### What Nix Actually Does

This project uses Nix to create a **reproducible, self-contained AppImage**:

```
┌─────────────────────────────────────────────────────────────┐
│                    Clearsky AppImage                        │
├─────────────────────────────────────────────────────────────┤
│  • Electron app (main.js, index.html)                       │
│  • Node.js runtime                                          │
│  • Podman (container runtime)                               │
│  • immich-go (photo import)                                 │
│  • tailscale (remote access)                                │
│  • All shared libraries                                     │
│  • Wrapper script (sets PATH, LD_LIBRARY_PATH)             │
└─────────────────────────────────────────────────────────────┘
```

### Nix Files Explained

#### `flake.nix` - The Build Definition

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      clearsky-appimage = pkgs.callPackage ./appimage.nix {};
    in {
      packages.x86_64-linux.default = clearsky-appimage;
    };
}
```

**What it does:**
- Imports nixpkgs for x86_64-linux
- Calls `appimage.nix` to build the AppImage
- Exports it as `packages.default`

#### `appimage.nix` - The AppImage Builder

```nix
{ lib, stdenv, appimageTools, nodejs, electron, makeWrapper, podman, immich-go, tailscale }:

appimageTools.wrapAppImage {
  name = "clearsky";
  version = "1.0.0";
  
  src = ./app;  # Your Electron app
  
  extraPkgs = pkgs: [
    podman      # Bundled into AppImage
    immich-go   # Bundled into AppImage
    tailscale   # Bundled into AppImage
  ];
  
  extraInstallCommands = ''
    # Create wrapper that sets PATH to include bundled tools
    makeWrapper ${nodejs}/bin/node $out/bin/clearsky \
      --add-flags "$out/share/clearsky/main.js" \
      --set PATH "${podman}/bin:${immich-go}/bin:$PATH"
  '';
}
```

**What it does:**
- Takes your Electron app
- Wraps it with Podman, immich-go, tailscale
- Creates a self-contained AppImage
- Sets up PATH so bundled tools work

#### `default.nix` - Alternative Entry Point

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./appimage.nix {}
```

**What it does:**
- Same as flake.nix but uses `<nixpkgs>` syntax
- Works without flakes enabled

### Build Process

```bash
# 1. Nix evaluates flake.nix
# 2. Calls appimage.nix with all dependencies
# 3. appimage.nix calls appimageTools.wrapAppImage
# 4. Nix fetches all dependencies (podman, immich-go, etc.)
# 5. Creates wrapper script that bundles everything
# 6. AppImage is created with all dependencies

nix build
# Result: ./result/bin/clearsky (self-contained AppImage)
```

### What Gets Bundled

| Package | Purpose | Size Estimate |
|---------|---------|---------------|
| nodejs | Node.js runtime | ~50MB |
| electron | Desktop framework | ~100MB |
| podman | Container runtime | ~20MB |
| immich-go | Photo import tool | ~5MB |
| tailscale | Remote access | ~3MB |
| Libraries | Shared libs | ~100MB |
| **Total** | | **~280MB+** |

### Why This Is Better

| Approach | Reproducible? | Self-Contained? | NixOS Friendly? |
|----------|--------------|-----------------|-----------------|
| npm build | ❌ | ❌ | ❌ |
| Nix build | ✅ | ✅ | ✅ |

### For the NixOS Hackathon

This implementation demonstrates:
1. ✅ **Nix reproducibility** - Same build every time
2. ✅ **Self-contained AppImage** - Works without user installing anything
3. ✅ **Declarative dependencies** - Clear list in Nix expressions
4. ✅ **Atomic updates** - Replace entire AppImage
5. ✅ **Sandboxed builds** - No contamination from build host

### Build Commands

```bash
# Build AppImage (Nix)
nix build

# Build AppImage (Nix with explicit flake)
nix build .#appimage

# Enter dev shell
nix-shell

# Build with npm (fallback)
cd app && npm run build
```

### Testing

```bash
# Test the AppImage
./result/bin/clearsky --version

# Check it's a valid AppImage
appimage-info ./result/bin/clearsky
```