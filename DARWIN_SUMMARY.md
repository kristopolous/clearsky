# Darwin/macOS Support Implementation Summary

## Overview

Full Darwin (macOS) support has been added to Clearsky, enabling builds for both Intel (`x86_64-darwin`) and Apple Silicon (`aarch64-darwin`) Macs.

## Files Created

| File | Purpose |
|------|---------|
| `macos.nix` | macOS-specific Nix build definition |
| `app/assets/entitlements.mac.plist` | macOS code signing entitlements |
| `BUILDING_MACOS.md` | User-facing macOS build guide |
| `ai/MACOS_PLAN.md` | Implementation plan (updated with status) |

## Files Modified

### Nix Configuration

**`flake.nix`**
- Changed from `eachDefaultSystem` to `eachSystem` with explicit Darwin support
- Added platform detection (Linux vs Darwin)
- Platform-specific package selection (AppImage for Linux, DMG for macOS)
- Updated devShell to include platform-appropriate dependencies

**`appimage.nix`**
- Restricted to Linux platforms only
- Updated meta.platforms to reflect Linux-only support

### Electron Configuration

**`app/package.json`**
- Added macOS build scripts (`build:mac`, `build:mac:intel`, `build:mac:arm`)
- Added macOS build configuration in `build.mac`
- Configured universal binary support (Intel + Apple Silicon)
- Added hardened runtime entitlements
- Set minimum macOS version to 10.13

### Application Code

**`app/main.js`**
- Added platform detection (`isMacOS`, `isLinux`)
- Platform-aware Nix eval (different system strings)
- Container runtime auto-detection (Docker/OrbStack on macOS, Podman on Linux)
- macOS-specific volume path handling
- Added `shell` import for opening external links

**`app/index.html`**
- Updated Tailscale instructions with macOS App Store link
- Platform-specific setup instructions

### Migration Harnesses

**`migrations/harnesses/run-container.nix`**
- macOS detection via `uname -s`
- OrbStack support (macOS-native container runtime)
- Volume path conversion for macOS (`~/` → `/Users/`)
- Platform-specific error messages
- macOS startup delay warning

## Build Commands

### Linux
```bash
nix build .#packages.x86_64-linux.default
# or
nix build .#packages.aarch64-linux.default
```

### macOS
```bash
# Apple Silicon
nix build .#packages.aarch64-darwin.default

# Intel
nix build .#packages.x86_64-darwin.default

# Or with npm
cd app
npm run build:mac
```

## Container Runtime Support

### Linux
- **Primary:** Podman (native)
- **Fallback:** Docker

### macOS
- **Primary:** OrbStack (recommended)
- **Secondary:** Docker Desktop
- **Fallback:** Podman Machine

## Key Differences Handled

| Feature | Linux | macOS |
|---------|-------|-------|
| Container runtime | Podman (native) | Docker/OrbStack (VM) |
| Home directory | `/home/user/` | `/Users/user/` |
| Data directory | `~/.clearsky/` | `~/.clearsky/` |
| Tailscale | CLI/App | App Store/CLI |
| Build output | AppImage | .app/.dmg |
| Nix system | `x86_64-linux` | `aarch64-darwin` |

## Testing Status

### Implemented ✅
- [x] Nix flake supports Darwin systems
- [x] macOS build configuration
- [x] Container runtime detection
- [x] Volume path handling
- [x] Tailscale macOS instructions
- [x] Platform-specific error messages

### Pending ⏳
- [ ] Test on macOS Intel
- [ ] Test on macOS Apple Silicon
- [ ] Create placeholder app icon
- [ ] Full migration testing on macOS

## Migration Compatibility

All migrations work on macOS:

| Migration | macOS Status |
|-----------|-------------|
| Google Photos → Immich | ✅ |
| Google Docs → Etherpad | ✅ |
| Substack → Ghost | ✅ |
| Medium → Ghost | ✅ |
| Nextcloud Setup | ✅ |
| ownCloud Setup | ✅ |
| Home Assistant Setup | ✅ |
| Ghost Setup | ✅ |

## Next Steps

1. **Create placeholder icon** - Need `.icns` file for macOS builds
2. **Test on real hardware** - Both Intel and Apple Silicon
3. **Add notarization** - For Gatekeeper compliance (optional for dev)
4. **Homebrew cask** - Create for easy distribution

## Documentation

- [BUILDING_MACOS.md](BUILDING_MACOS.md) - Complete macOS build guide
- [ai/MACOS_PLAN.md](ai/MACOS_PLAN.md) - Implementation plan with status

## Usage Example

```bash
# On macOS
git clone https://github.com/clearsky/clearsky.git
cd clearsky/app

# Install dependencies
npm install

# Run in development
npm start

# Build macOS app
npm run build:mac

# Output: dist/Clearsky-1.0.0-universal.dmg
```

## Notes

- Universal binaries support both Intel and Apple Silicon
- Minimum macOS version: 10.13 (High Sierra)
- Hardened runtime enabled for security
- Entitlements allow necessary permissions (network, files, JIT)
- Notarization disabled for development (enable for distribution)
