# Simple Bootstrap Strategy

## Core Insight

We don't need to bundle everything. We need:
1. **Opinionated defaults** - Assume sensible setup
2. **Clean containerization** - Use what's available
3. **Nix local to user** - If they have it, great. If not, fallback.

## Architecture

```
Clearsky AppImage
│
├── If container runtime exists → Use it
├── If Nix exists → Use it for migrations
│
└── If neither exists:
    ├── Show simple setup guide
    └── Offer one-click installers
```

## Implementation

### 1. AppImage Already Solves This

The AppImage bundles:
- ✅ Electron runtime
- ✅ Node.js
- ✅ All app dependencies

**What it doesn't bundle (and shouldn't):**
- ❌ Container runtime (system-level)
- ❌ Nix (user-level tool)

### 2. Opinionated Runtime Detection

Priority order:
```javascript
const RUNTIME_PRIORITY = [
  'orbstack',      // macOS - fastest, native
  'podman',        // Linux - rootless, secure
  'docker',        // Fallback - ubiquitous
];
```

### 3. Simple Fallback for Migrations

Instead of pre-building everything:

```javascript
async function runMigration(name, options) {
  // Try Nix first (if user has it)
  if (await hasNix()) {
    return runNixMigration(name, options);
  }
  
  // Fallback to shell script
  return runShellMigration(name, options);
}
```

### 4. One-Click Installers (Not Bundled)

When runtime is missing:

```
┌─────────────────────────────────────────┐
│  Container Runtime Required             │
│                                         │
│  Clearsky needs a container runtime.   │
│                                         │
│  macOS:                                  │
│  [Install OrbStack] ← One command       │
│  [Install Docker Desktop]               │
│                                         │
│  Linux:                                  │
│  [Install Podman] ← Shows apt/dnf cmd  │
│                                         │
│  ℹ️ These install system-wide, not     │
│     bundled with the app.               │
└─────────────────────────────────────────┘
```

## File Changes

### `app/bootstrap.js` (New, Simple)

```javascript
const { execSync } = require('child_process');

class Bootstrap {
  constructor() {
    this.runtime = this.detectRuntime();
    this.hasNix = this.checkNix();
  }

  detectRuntime() {
    // Check in priority order
    const runtimes = ['orb', 'podman', 'docker'];
    for (const cmd of runtimes) {
      try {
        execSync(`which ${cmd}`, { stdio: 'ignore' });
        return cmd === 'orb' ? 'orbstack' : cmd;
      } catch (e) {}
    }
    return null;
  }

  checkNix() {
    try {
      execSync('which nix', { stdio: 'ignore' });
      return true;
    } catch (e) {
      return false;
    }
  }

  async ensureReady() {
    if (!this.runtime) {
      throw new Error('No container runtime found');
    }
    // Runtime is ready
    return true;
  }
}

module.exports = Bootstrap;
```

### `app/main.js` (Updated)

```javascript
const Bootstrap = require('./bootstrap');
const bootstrap = new Bootstrap();

// On app ready
app.on('ready', async () => {
  try {
    await bootstrap.ensureReady();
    createWindow();
  } catch (error) {
    showRuntimeMissingDialog();
  }
});
```

### `app/index.html` (Updated)

Add runtime check UI:

```html
<div id="runtime-missing" style="display: none;">
  <h2>Container Runtime Required</h2>
  
  <div id="macos-install">
    <button onclick="installOrbStack()">Install OrbStack</button>
    <button onclick="openDockerDesktop()">Docker Desktop</button>
  </div>
  
  <div id="linux-install">
    <p>Run in terminal:</p>
    <code>sudo apt install podman</code>
  </div>
</div>
```

## What This Solves

✅ **App stays small** - No bundled runtimes (~50-500MB saved)
✅ **User choice** - Pick their preferred runtime
✅ **System integration** - Runtimes update independently
✅ **Clean uninstall** - Just remove app, runtime stays
✅ **Nix optional** - Works with or without

## What It Doesn't Solve

❌ **First-time friction** - Still need to install runtime
❌ **Nix requirement** - Migrations need fallback

## Tradeoffs

| Approach | Bundle Everything | Simple Bootstrap |
|----------|------------------|------------------|
| App size | ~600MB | ~150MB |
| First run | Works immediately | May need install |
| Updates | App updates everything | System manages runtime |
| Flexibility | Locked to bundled version | User can choose |
| Uninstall | Complex | Simple |

## Recommendation

**Start with Simple Bootstrap:**
1. Detect what's available
2. Show clear install instructions if missing
3. Support both Nix and shell migrations

**If friction is too high, then:**
- Bundle OrbStack CLI for macOS (not full app)
- Keep Podman/Docker as system installs

---

## Implementation Checklist

- [ ] Create `app/bootstrap.js`
- [ ] Add runtime detection to `main.js`
- [ ] Add missing runtime UI to `index.html`
- [ ] Create shell script fallbacks for migrations
- [ ] Test on clean macOS install
