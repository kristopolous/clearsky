# Clearsky: No More Clouds

## Quick Start (Without Nix)

This project can be built and run **without Nix** using standard npm/electron tooling.

### Prerequisites

- Node.js 18+
- npm
- Podman (for container orchestration - installed on target system, not for building)

### Build

```bash
cd app
npm install
npm run build:linux
```

The AppImage will be in `dist/`

### Run

```bash
npm start
```

### How to Use

1. Double-click the AppImage to run
2. Select services (Google Photos, Google Drive, iCloud)
3. Follow export instructions
4. Drag and drop ZIP files
5. Watch import progress
6. Preview in Immich dashboard
7. Commit or rollback

## With Nix (Optional)

If you have Nix installed, use the flake for reproducible builds:

```bash
nix build
nix-shell
```

## Dependencies

| Runtime | Purpose |
|---------|---------|
| Podman | Container runtime for Immich/Tailscale |
| Node.js | Electron framework |
| immich-go | Photo import tool |
| tailscale | Remote access |

## Build System Comparison

### Without Nix (npm/electron-builder)
- ✅ Simpler setup
- ✅ No Nix required
- ✅ Standard Electron ecosystem
- ❌ Dependencies not bundled (user needs Podman installed)
- ❌ Less reproducible across systems

### With Nix (flakes)
- ✅ Fully reproducible builds
- ✅ All dependencies bundled in AppImage
- ✅ Works on any Nix-compatible system
- ❌ Requires Nix to build
- ❌ Steeper learning curve

## Recommended Approach

For the NixOS Hackathon, use Nix to build a truly self-contained AppImage:

```bash
nix build
```

For general use, electron-builder is sufficient if users have Podman installed.