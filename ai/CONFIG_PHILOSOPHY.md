# Clearsky Configuration Philosophy

## Core Principle

**Users aren't stupid, they just can't be trusted to have technical opinions.**

This means:
- **Default**: Everything should "just work" with opinionated defaults
- **Optional**: Power users can provide their own config if they have opinions
- **No judgment**: Both paths are equally valid

## Configuration Layers

```
┌─────────────────────────────────────────────────────────┐
│  Layer 1: Opinionated Defaults (99% of users)          │
│  - Auto-detect container runtime                       │
│  - Sensible ports (2283, 8080, etc.)                   │
│  - Data in ~/.clearsky                                 │
│  - No config file needed                               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Layer 2: User Config (1% of users)                    │
│  - clearsky.toml or clearsky.json                      │
│  - Override ports, paths, runtimes                     │
│  - Specify custom migrations                           │
│  - Fine-tune behavior                                  │
└─────────────────────────────────────────────────────────┘
```

## Default Behavior (No Config)

```javascript
const defaults = {
  runtime: 'auto-detect',  // OrbStack > Podman > Docker
  dataDir: '~/.clearsky',
  services: {
    immich: { port: 2283 },
    nextcloud: { port: 8080 },
    ghost: { port: 2368 },
    // ... etc
  },
  migrations: 'bundled',  // Use pre-built migrations
  nix: 'optional'  // Use if available, fallback to shell
};
```

## Config File Support

### Location

```
~/.clearsky/config.toml    # User config
./clearsky.toml            # Project config (optional)
```

### Example Config

```toml
# clearsky.toml

# Override container runtime
runtime = "podman"  # or "docker", "orbstack"

# Custom data directory
dataDir = "/Volumes/SSD/clearsky-data"

# Override service ports
[services.immich]
port = 9090

[services.nextcloud]
port = 9091

# Use custom migrations
[migrations]
source = "nix"  # or "shell", "custom"
customPath = "~/my-migrations"

# Advanced: custom container options
[containers]
extraArgs = ["--memory=4g", "--cpus=2"]
```

### Config Loading Order

```javascript
function loadConfig() {
  // Start with defaults
  let config = { ...defaults };
  
  // Load user config (~/.clearsky/config.toml)
  const userConfig = loadUserConfig();
  if (userConfig) {
    config = merge(config, userConfig);
  }
  
  // Load project config (./clearsky.toml)
  const projectConfig = loadProjectConfig();
  if (projectConfig) {
    config = merge(config, projectConfig);
  }
  
  // CLI flags override everything
  const cliConfig = parseCLIArgs();
  config = merge(config, cliConfig);
  
  return config;
}
```

## Implementation

### bootstrap.js (Updated)

```javascript
const fs = require('fs');
const path = require('path');
const toml = require('toml');  // or use JSON

class Bootstrap {
  constructor() {
    this.config = this.loadConfig();
    this.runtime = this.detectRuntime();
  }

  loadConfig() {
    const configPaths = [
      path.join(os.homedir(), '.clearsky', 'config.toml'),
      path.join(process.cwd(), 'clearsky.toml')
    ];

    for (const configPath of configPaths) {
      if (fs.existsSync(configPath)) {
        try {
          const content = fs.readFileSync(configPath, 'utf-8');
          return toml.parse(content);
        } catch (e) {
          console.warn(`Failed to load config from ${configPath}: ${e.message}`);
        }
      }
    }

    return null;  // Use defaults
  }

  detectRuntime() {
    // If config specifies runtime, use it
    if (this.config?.runtime) {
      console.log(`Using runtime from config: ${this.config.runtime}`);
      return this.config.runtime;
    }

    // Otherwise auto-detect
    const runtimes = [
      { cmd: 'orb', name: 'orbstack' },
      { cmd: 'podman', name: 'podman' },
      { cmd: 'docker', name: 'docker' }
    ];

    for (const { cmd, name } of runtimes) {
      try {
        execSync(`which ${cmd}`, { stdio: 'ignore' });
        execSync(`${cmd} --version`, { stdio: 'ignore' });
        console.log(`Auto-detected runtime: ${name}`);
        return name;
      } catch (e) {}
    }

    return null;
  }
}
```

## User Stories

### Story 1: Non-Technical User (Sarah)

**Scenario**: Sarah wants to migrate her photos from Google Photos.

**Experience**:
1. Downloads Clearsky
2. Double-clicks AppImage
3. App detects OrbStack, uses it
4. Follows wizard, migrates photos
5. Done

**Config files**: None needed, none created.

### Story 2: Power User (Alex)

**Scenario**: Alex has strong opinions about container runtime and ports.

**Experience**:
1. Creates `~/.clearsky/config.toml`:
   ```toml
   runtime = "podman"
   
   [services.immich]
   port = 9999
   
   [containers]
   extraArgs = ["--memory=8g"]
   ```
2. Runs Clearsky
3. App uses Alex's config
4. Everything runs on Alex's terms

**Config files**: Respected, validated, used.

### Story 3: Developer (Jamie)

**Scenario**: Jamie wants to test a custom migration.

**Experience**:
1. Creates `./clearsky.toml` in project:
   ```toml
   [migrations]
   source = "custom"
   customPath = "./my-migrations"
   ```
2. Runs Clearsky in dev mode
3. Custom migrations load
4. Tests new migration

**Config files**: Project-local, doesn't affect global config.

## Benefits

| Approach | Opinionated Defaults | Config Override | Result |
|----------|-------------------|-----------------|--------|
| **Sarah** | ✅ Yes | ❌ No | Just works |
| **Alex** | ✅ Yes | ✅ Yes | Alex's way |
| **Jamie** | ✅ Yes | ✅ Yes (project) | Dev-friendly |

## Implementation Checklist

- [ ] Create `app/config.js` - Config loader
- [ ] Add TOML support (`npm install toml`)
- [ ] Update `bootstrap.js` to use config
- [ ] Document config options in README
- [ ] Add example config file
- [ ] Test with and without config

## Notes

- **No config is valid** - Defaults should work
- **Config is optional** - Don't require it
- **Validate config** - Show clear errors if invalid
- **Document thoroughly** - Power users need docs
- **Don't judge** - Both paths are fine

---

**Philosophy in one line:**

> Defaults for everyone, config for those who care.
