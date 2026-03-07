# Clearsky Bootstrapping Plan

## Problem

Current state requires users to manually install:
- Node.js (for development)
- Docker/OrbStack/Podman (container runtime)
- Nix (optional, for reproducible builds)

**This is unacceptable for non-technical users.** The app should "just work" like any other desktop application.

## Solution: Self-Bootstrapping Application

The Electron app must:
1. **Detect** what's missing on first launch
2. **Guide** users through installation (or bundle dependencies)
3. **Manage** the container runtime lifecycle
4. **Clean up** completely on uninstall

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│  Clearsky Electron App                                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Bootstrap Manager                                 │  │
│  │  - Detect missing dependencies                     │  │
│  │  - Install/guide installation                      │  │
│  │  - Manage container runtime                        │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Migration Orchestrator                            │  │
│  │  - Run migrations (via bundled Nix or scripts)     │  │
│  │  - Manage service lifecycle                        │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
         │
         ├─► Bundle container runtime? (OrbStack CLI)
         ├─► Bundle Nix? (nix-static)
         └─► Use system Docker if available
```

---

## Implementation Strategy

### Phase 1: Dependency Detection

**File:** `app/bootstrap/dependency-checker.js`

```javascript
const { execSync } = require('child_process');

function checkDependencies() {
  return {
    node: checkCommand('node'),
    docker: checkCommand('docker'),
    orbstack: checkCommand('orb'),
    podman: checkCommand('podman'),
    nix: checkCommand('nix'),
    containerRuntime: detectContainerRuntime()
  };
}

function detectContainerRuntime() {
  // Priority: OrbStack > Docker Desktop > Podman
  if (hasOrbStack()) return 'orbstack';
  if (hasDockerDesktop()) return 'docker';
  if (hasPodman()) return 'podman';
  return null;
}
```

### Phase 2: Installation Options

#### Option A: Bundle OrbStack CLI (Recommended for macOS)

**Pros:**
- Lightweight (~50MB)
- macOS-native
- Docker-compatible
- No VM setup needed

**Cons:**
- License (free for personal, paid for commercial)
- macOS only

**Implementation:**
```javascript
// app/bootstrap/installers/orbstack.js
async function installOrbStack() {
  // Download OrbStack CLI
  // Install to app bundle
  // Initialize automatically
}
```

#### Option B: Bundle Docker Desktop

**Pros:**
- Cross-platform
- Well-known

**Cons:**
- Large (~500MB)
- Requires GUI setup
- Resource-heavy

#### Option C: Bundle Podman

**Pros:**
- Open source
- Rootless by default

**Cons:**
- Requires VM on macOS
- More complex setup

#### Option D: Hybrid Approach (Recommended)

1. **Check for existing runtime** - Use what's installed
2. **Offer OrbStack** - One-click install for macOS
3. **Offer Docker Desktop** - Fallback with instructions
4. **Bundle minimal CLI** - Include OrbStack CLI in app bundle

---

### Phase 3: Nix Handling

**Problem:** Migrations are Nix flakes, but Nix is hard to install.

**Solutions:**

#### Option A: Pre-build Migrations

Instead of running `nix build` at runtime:
1. Build migrations during app build
2. Bundle compiled binaries in app
3. Run binaries directly

```nix
# In flake.nix
# Build migrations at build time
packages.default = pkgs.buildElectronApp {
  # ... electron config
  extraBinaries = [
    migrations.google-photos-to-immich
    migrations.ghost-setup
    # ... all migrations
  ];
};
```

**Pros:**
- No Nix needed at runtime
- Faster startup
- Smaller download

**Cons:**
- Larger app bundle
- Less flexible (can't add migrations dynamically)

#### Option B: Bundle Nix (nix-static)

Use [nix-static](https://github.com/nix-community/nix-static) or similar.

**Pros:**
- Keep dynamic migration loading
- Reproducible at runtime

**Cons:**
- Large bundle
- Complex

#### Option C: Shell Script Fallback

Convert migrations to plain shell scripts that:
- Call docker/podman directly
- Use curl for downloads
- No Nix needed

**Pros:**
- Simple
- No dependencies

**Cons:**
- Lose Nix reproducibility
- More maintenance

### Recommended: **Option A + C Hybrid**

- **Bundle pre-built Nix binaries** for common migrations
- **Include shell script fallback** for flexibility
- **No Nix required at runtime**

---

### Phase 4: Lifecycle Management

**File:** `app/bootstrap/runtime-manager.js`

```javascript
class RuntimeManager {
  async start() {
    // Start container runtime if needed
    if (this.runtime === 'orbstack') {
      await this.ensureOrbStackRunning();
    }
  }

  async stop() {
    // Clean shutdown
  }

  async ensureOrbStackRunning() {
    // Check if OrbStack daemon is running
    // If not, start it
    // Wait for ready
  }
}
```

### Phase 5: Clean Uninstall

**File:** `app/bootstrap/uninstall.js`

```javascript
async function cleanup() {
  // Stop all containers
  await exec('docker stop clearsky-*');
  
  // Remove containers
  await exec('docker rm clearsky-*');
  
  // Remove images
  await exec('docker rmi clearsky-*');
  
  // Remove data directory
  await fs.rm('~/.clearsky', { recursive: true });
  
  // Remove app support files
  await fs.rm('~/Library/Application Support/Clearsky', { recursive: true });
}
```

---

## Platform-Specific Plans

### macOS

**Bootstrap Flow:**
1. App launches
2. Check for container runtime
3. If missing:
   - Offer to install bundled OrbStack CLI
   - Or guide to Docker Desktop
4. Check for migrations (pre-built or build with bundled Nix)
5. Ready

**Uninstall:**
1. Stop containers
2. Remove `~/.clearsky`
3. Remove app support files
4. Optionally remove OrbStack (if app installed it)

### Linux

**Bootstrap Flow:**
1. App launches
2. Check for Podman (preferred) or Docker
3. If missing:
   - Show distro-specific install command
   - Or use AppImage with bundled Podman
4. Run migrations (pre-built binaries)
5. Ready

### Windows (Future)

**Bootstrap Flow:**
1. App launches
2. Check for Docker Desktop or WSL2
3. If missing:
   - Guide to Docker Desktop installation
4. Run migrations (pre-built binaries)
5. Ready

---

## File Structure

```
app/
├── bootstrap/
│   ├── index.js              # Main bootstrap orchestrator
│   ├── dependency-checker.js # Detect what's installed
│   ├── runtime-manager.js    # Manage container runtime
│   ├── installers/
│   │   ├── orbstack.js       # OrbStack installer
│   │   ├── docker-desktop.js # Docker Desktop guide
│   │   └── podman.js         # Podman installer
│   ├── migrations/
│   │   ├── runner.js         # Run pre-built migrations
│   │   └── binaries/         # Pre-built migration binaries
│   └── uninstall.js          # Clean uninstall logic
├── main.js                   # Updated to use bootstrap
└── index.html                # Updated UI for bootstrap
```

---

## Updated User Experience

### First Launch (No Dependencies)

```
┌─────────────────────────────────────────────────────────┐
│  Welcome to Clearsky                                    │
│                                                         │
│  Clearsky needs a container runtime to run services.   │
│                                                         │
│  ✓ Detected: macOS                                      │
│  ✗ Missing: Container runtime                          │
│                                                         │
│  Recommended: OrbStack (free for personal use)         │
│  - Lightweight (~50MB)                                  │
│  - Fast startup                                         │
│  - macOS-native                                         │
│                                                         │
│  [Install OrbStack]  [Use Docker Desktop]              │
│                                                         │
│  ℹ️ OrbStack will be installed to your Applications    │
│     folder. You can uninstall it anytime.              │
└─────────────────────────────────────────────────────────┘
```

### First Launch (Runtime Installed)

```
┌─────────────────────────────────────────────────────────┐
│  Welcome to Clearsky                                    │
│                                                         │
│  ✓ Container runtime detected: OrbStack                │
│  ✓ Ready to migrate                                     │
│                                                         │
│  [Get Started]                                          │
└─────────────────────────────────────────────────────────┘
```

### Uninstall

```
┌─────────────────────────────────────────────────────────┐
│  Uninstall Clearsky                                     │
│                                                         │
│  This will:                                             │
│  ✓ Stop all running services                           │
│  ✓ Remove migrated data (~/.clearsky)                  │
│  ✓ Remove app configuration                            │
│  ☐ Also uninstall OrbStack (if installed by Clearsky)  │
│                                                         │
│  Your cloud data is safe - nothing will be deleted.    │
│                                                         │
│  [Uninstall]  [Cancel]                                  │
└─────────────────────────────────────────────────────────┘
```

---

## Implementation Priority

### P0 (Required for Non-Technical Users)
1. **Dependency detection** - Know what's missing
2. **OrbStack bundling** - One-click install for macOS
3. **Pre-built migrations** - No Nix at runtime
4. **Clean uninstall** - Remove all traces

### P1 (Should Have)
5. **Docker Desktop fallback** - For users who prefer it
6. **Linux support** - Bundle Podman or detect system
7. **Lifecycle management** - Start/stop runtime

### P2 (Nice to Have)
8. **Windows support** - Docker Desktop or WSL2
9. **Nix bundling** - For dynamic migrations
10. **Auto-updates** - For runtime and migrations

---

## Next Steps

1. **Create `app/bootstrap/` directory structure**
2. **Implement dependency checker**
3. **Bundle OrbStack CLI in app bundle**
4. **Convert migrations to pre-built binaries**
5. **Add uninstall logic**
6. **Update Electron app to use bootstrap on launch**

---

## Notes

- **License compliance** - OrbStack free for personal use, need commercial license for paid deployments
- **App size** - Bundling OrbStack adds ~50MB, pre-built migrations add ~100MB
- **Security** - Verify downloaded binaries with signatures
- **Updates** - Need mechanism to update bundled runtime and migrations
