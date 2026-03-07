# Clearsky Test Framework

## Overview

Automated tests for Clearsky migrations and services. Tests are designed to be:
- **Container runtime agnostic** - Works with nix-containers, Podman, or Docker
- **Cross-platform** - Designed for Linux, macOS, and Windows (via Docker Desktop)
- **Isolated** - Each test cleans up after itself
- **Informative** - Clear pass/fail output with verbose logging

## Running Tests

```bash
# Run all tests
node test.js

# Run specific test
node test.js --test scaffolding
node test.js --test tailscale
node test.js --test immich
node test.js --test etherpad
node test.js --test migration

# Run with verbose output
node test.js --verbose

# Run specific test with verbose
node test.js --test immich --verbose
```

## Test Suite

### Test 1: Basic Scaffolding

Verifies the project structure is correct:
- ✅ Project files exist (flake.nix, appimage.nix, etc.)
- ✅ Migration directories exist
- ✅ Nix is installed
- ✅ Container runtime is available

### Test 2: Tailscale Startup

Tests Tailscale container lifecycle:
- ✅ Container starts successfully
- ✅ Container is running
- ✅ Cleanup works

**Runtime:** ~10 seconds

### Test 3: Immich Startup

Tests Immich container and API:
- ✅ Container starts successfully
- ✅ Service becomes accessible
- ✅ Health endpoint responds
- ✅ Cleanup works

**Runtime:** ~60-120 seconds (Immich takes time to initialize)

### Test 4: Etherpad Startup

Tests Etherpad container and web UI:
- ✅ Container starts successfully
- ✅ Web UI becomes accessible
- ✅ Cleanup works

**Runtime:** ~30 seconds

### Test 5: Migration (Placeholder)

Placeholder for Google Photos migration test:
- ⏭️ Requires `GOOGLE_PHOTOS_API_KEY` environment variable
- ⏭️ Will test actual migration with cleanup

## Requirements

### Container Runtime

One of the following must be installed:
- **nix-containers** (preferred on NixOS)
- **Podman** (Linux)
- **Docker** (Linux, macOS, Windows)

The test framework auto-detects which is available.

### Node.js

Node.js 18+ is required to run the tests.

### For Migration Test

To run the migration test (when implemented):
```bash
export GOOGLE_PHOTOS_API_KEY=AIzaSy...
node test.js --test migration
```

## Output

### Colors
- 🟢 Green = Pass
- 🔴 Red = Fail
- 🟡 Yellow = Skip/Warning
- 🔵 Blue = Info

### Example Output

```
╔═══════════════════════════════════════════════════════════╗
║  Clearsky Test Suite                                      ║
╚═══════════════════════════════════════════════════════════╝

Test directory: /tmp/clearsky-test-123456
Data directory: /home/user/.clearsky-test

┌─────────────────────────────────────────────────────────────
│ Test 1: Basic Scaffolding
└─────────────────────────────────────────────────────────────
  ▶ Checking project structure...
  ✓ Found: flake.nix
  ✓ Found: appimage.nix
  ...

┌─────────────────────────────────────────────────────────────
│ Test Results
└─────────────────────────────────────────────────────────────
  ✓ Scaffolding: PASS
  ✓ Tailscale: PASS
  ✓ Immich: PASS
  ✓ Etherpad: PASS
  ⏭️ Migration: SKIP

  Summary:
    Passed:  4
    Failed:  0
    Skipped: 1
```

## Architecture

### Test Structure

```
test.js
├── testScaffolding()    # Verify project structure
├── testTailscale()      # Test Tailscale container
├── testImmich()         # Test Immich container + API
├── testEtherpad()       # Test Etherpad container + UI
└── testMigration()      # Test actual migration (placeholder)
```

### Container Runtime Detection

```javascript
getContainerRuntime()
├── Check nix-container-run
├── Check podman
└── Check docker
```

### Cleanup

Each test:
1. Stops existing test containers
2. Creates isolated test directories
3. Runs the test
4. Cleans up containers and files

## Future Improvements

1. **Full Migration Test** - Implement actual Google Photos migration with test data
2. **Nextcloud Test** - Add test for Nextcloud setup
3. **Home Assistant Test** - Add test for Home Assistant setup
4. **Parallel Execution** - Run independent tests in parallel
5. **JUnit Output** - Generate CI-compatible test reports
6. **Coverage Reports** - Track test coverage of migrations

## Troubleshooting

### "No container runtime found"

Install a container runtime:
```bash
# NixOS
nix-env -iA nixos.nix-containers

# Ubuntu/Debian
sudo apt install podman

# macOS (with Homebrew)
brew install podman

# Windows/macOS
# Install Docker Desktop
```

### "Immich did not become accessible"

Immich can take 2+ minutes to start on slow connections. The test waits up to 120 seconds. Check:
- Internet connection (for image pull)
- Available disk space
- Container logs: `docker logs clearsky-test-immich`

### "Nix is not installed"

The scaffolding test checks for Nix. Install from:
https://install.nixos.org

Or skip Nix-dependent tests.
