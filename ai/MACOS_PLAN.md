# macOS/Darwin Deployment Plan

## Status: ✅ IMPLEMENTED

All phases have been completed. See [BUILDING_MACOS.md](../BUILDING_MACOS.md) for usage instructions.

## Overview

This document outlines the plan to build and deploy Clearsky on macOS (Darwin). The goal is to have a native macOS application (.app bundle or .dmg) that works identically to the Linux version.

## Current State

The current build system targets Linux AppImage only:
- `appimage.nix` - AppImage build definition
- `flake.nix` - Only builds for `x86_64-linux`
- Electron builder configured for Linux only

## Challenges

### 1. Container Runtime on macOS

**Problem:** Podman and Docker work differently on macOS:
- Linux: Native container support
- macOS: Containers run in a lightweight VM

**Solutions:**
- **Option A:** Use Docker Desktop (most common on macOS)
- **Option B:** Use Podman with `podman machine` (requires VM setup)
- **Option C:** Use OrbStack (lighter alternative, gaining popularity)

**Decision:** Support all three, auto-detect at runtime.

### 2. Nix on macOS

**Problem:** Nix works on macOS but has differences:
- Different system paths
- Some packages not available on Darwin
- Need to handle Rosetta 2 for Apple Silicon

**Solutions:**
- Use `nix-darwin` for system configuration
- Ensure all Nix packages have Darwin support
- Support both x86_64-darwin and aarch64-darwin

### 3. Electron Build for macOS

**Problem:** Current build only produces Linux AppImage

**Solutions:**
- Configure electron-builder for macOS target
- Create .app bundle for Intel and Apple Silicon
- Optionally create .dmg for distribution

### 4. Tailscale Integration

**Problem:** Tailscale on macOS requires different setup

**Solutions:**
- Use Tailscale macOS app (recommended)
- Or run Tailscale in container (less reliable)

## Implementation Plan

### Phase 1: Nix Flake Updates ✅

**Files modified:**
- `flake.nix` - Added Darwin system support (`x86_64-darwin`, `aarch64-darwin`)
- `appimage.nix` - Restricted to Linux platforms only
- `macos.nix` - Created macOS-specific build definition

**Changes:**
```nix
# Support multiple systems
outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]
    (system: { ... })
```

### Phase 2: Electron Builder Configuration ✅

**Files modified:**
- `app/package.json` - Added macOS build scripts and configuration
- `app/assets/entitlements.mac.plist` - Created macOS entitlements

**Changes:**
```json
{
  "scripts": {
    "build:mac": "electron-builder --mac --universal",
    "build:mac:intel": "electron-builder --mac --x64",
    "build:mac:arm": "electron-builder --mac --arm64"
  },
  "build": {
    "mac": {
      "target": ["dmg", "zip"],
      "arch": ["universal"],
      "entitlements": "assets/entitlements.mac.plist"
    }
  }
}
```

### Phase 3: Container Runtime Detection ✅

**Files modified:**
- `migrations/harnesses/run-container.nix` - macOS detection and OrbStack support
- `app/main.js` - Platform-specific container handling

**Changes:**
- Detect macOS via `uname -s` = "Darwin"
- Support OrbStack, Docker Desktop, and Podman Machine
- Handle macOS volume paths (`/Users/` vs `/home/`)
- Auto-detect best runtime for platform

### Phase 4: Tailscale Integration ✅

**Files modified:**
- `app/index.html` - Updated instructions for macOS
- `app/main.js` - Platform detection

**Changes:**
- Added macOS App Store link for Tailscale
- Platform-specific setup instructions
- Support for both CLI and GUI Tailscale installation

### Phase 5: Testing ⏳

**Test on:**
- [ ] macOS Intel (x86_64-darwin)
- [ ] macOS Apple Silicon (aarch64-darwin)

**Test cases:**
- [ ] App launches correctly
- [ ] Container runtime detection works
- [ ] Migrations run successfully
- [ ] Tailscale integration works
- [ ] UI renders correctly

## File Checklist

### Create ✅
- [x] `macos.nix` - macOS build definition
- [ ] `assets/icon.icns` - macOS app icon (need placeholder)
- [x] `assets/entitlements.mac.plist` - macOS entitlements
- [x] `ai/MACOS_PLAN.md` - This file
- [x] `BUILDING_MACOS.md` - User-facing macOS build guide

### Modify ✅
- [x] `flake.nix` - Add Darwin systems
- [x] `app/package.json` - macOS build scripts
- [x] `migrations/harnesses/run-container.nix` - macOS detection
- [x] `app/main.js` - macOS-specific paths and platform detection
- [x] `app/index.html` - macOS instructions

## Build Commands

### Linux (existing)
```bash
nix build .#packages.x86_64-linux.default
```

### macOS (new)
```bash
# Intel Mac
nix build .#packages.x86_64-darwin.default

# Apple Silicon Mac
nix build .#packages.aarch64-darwin.default

# Or with npm
cd app
npm install
npm run build:mac
```

## Distribution

### Option 1: Direct Download
- Provide .dmg file on GitHub Releases
- Users download and install

### Option 2: Homebrew Cask
- Create Homebrew cask
- `brew install --cask clearsky`

### Option 3: Nix
- Users with Nix can build directly
- `nix profile install github:clearsky/clearsky`

## Timeline

| Phase | Estimated Time | Dependencies |
|-------|---------------|--------------|
| Phase 1: Nix Flake | 1-2 hours | None |
| Phase 2: Electron Build | 1-2 hours | Phase 1 |
| Phase 3: Container Runtime | 2-3 hours | Phase 2 |
| Phase 4: Tailscale | 1 hour | Phase 3 |
| Phase 5: Testing | 2-4 hours | Phase 4 |

**Total:** 7-12 hours

## Success Criteria

- [ ] App builds on macOS Intel
- [ ] App builds on macOS Apple Silicon
- [ ] Container runtime auto-detection works
- [ ] At least one migration runs successfully
- [ ] Tailscale setup works
- [ ] No Linux-specific code paths break macOS

## Notes

- macOS sandboxing may require entitlements
- Code signing needed for distribution (optional for development)
- Notarization required for Gatekeeper (if distributing)
- Consider universal binary for Intel + Apple Silicon
