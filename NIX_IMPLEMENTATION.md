# Clearsky: No More Clouds

## NixOS Hackathon - Nix Implementation

### The Nix Files (What We're Building For)

These Nix expressions define a **reproducible AppImage build** that bundles all dependencies:

| File | Purpose |
|------|---------|
| `flake.nix` | Nix flake entry point - defines inputs and outputs |
| `appimage.nix` | AppImage wrapper - bundles Electron app + dependencies |
| `default.nix` | Alternative entry point for non-flake Nix |

### How Nix Is Actually Used Here

**The key insight:** Nix doesn't just build the app - it **bundles all dependencies** into the AppImage:

```nix
appimageTools.wrapAppImage {
  src = ./app;  # Your Electron app
  
  extraPkgs = pkgs: [
    podman      # Container runtime (bundled!)
    immich-go   # Photo import tool (bundled!)
    tailscale   # Remote access (bundled!)
  ];
  
  # Nix creates a wrapper script that sets PATH to include these
}
```

### Build the AppImage

```bash
# Using Nix flakes (recommended)
nix build

# Using nix-build
nix-build -E 'with import <nixpkgs> {}; callPackage ./appimage.nix {}'

# The AppImage is created with ALL dependencies bundled
```

### What Gets Bundled

| Dependency | Nix Package | Purpose |
|------------|-------------|---------|
| Node.js | `nodejs` | Electron runtime |
| Electron | `electron` | Desktop framework |
| Podman | `podman` | Container runtime |
| immich-go | `immich-go` | Photo import tool |
| tailscale | `tailscale` | Remote access |

### Why This Matters for NixOS Hackathon

1. **Reproducibility** - Same build on every machine
2. **Dependency Isolation** - No conflicts with system packages
3. **Self-Contained** - Single AppImage file
4. **Declarative** - Clear dependency list in Nix expressions
5. **Atomic** - Easy version management via Nix

### Testing the Nix Build

```bash
# Check if Nix is installed
which nix

# If Nix is installed, build
nix build

# Verify the AppImage
file ./result/bin/clearsky
```

### If Nix Is NOT Installed

The project still works with npm:
```bash
cd app
npm install
npm run build
```

But you miss out on:
- Bundled dependencies (user needs Podman installed)
- Reproducible builds
- Nix-specific features