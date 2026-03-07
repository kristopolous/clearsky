# Refactored Clearsky with Migration Framework

## Architecture Changes

### Before (Monolithic)

```
app/
├── main.js          # Contains ALL migration logic
├── index.html       # UI with hardcoded migration steps
└── package.json

flake.nix           # Single monolithic build
```

**Problems:**
- Hard to add new migrations
- All code in one place
- No separation of concerns

### After (Modular)

```
app/
├── main.js          # Migration orchestrator (loads from flakes)
├── index.html       # Dynamic UI based on migrations
└── package.json

migrations/
├── flake.nix        # Migration registry
├── harnesses/       # Reusable components
│   ├── download.nix
│   ├── extract.nix
│   └── import-immich.nix
├── google-photos-to-immich/
│   ├── flake.nix
│   └── migrate.nix
└── registry.nix     # Load all migrations

flake.nix           # Integrates migrations
```

**Benefits:**
- Easy to add new migrations (just add a flake)
- Reusable harnesses
- Clear separation of concerns
- Third-party contributions

## Implementation Steps

### Step 1: Create Migration Loader in main.js

```javascript
// Load migrations from Nix
async function loadMigrations() {
  const { exec } = require('child_process');
  
  return new Promise((resolve, reject) => {
    exec('nix eval --raw .#migrations', (error, stdout, stderr) => {
      if (error) {
        reject(error);
        return;
      }
      
      const migrations = JSON.parse(stdout);
      resolve(migrations);
    });
  });
}

// UI shows available migrations
ipcMain.handle('get-migrations', async () => {
  return await loadMigrations();
});

// Run selected migration
ipcMain.handle('run-migration', async (event, migrationName) => {
  const migrationPath = migrations[migrationName].migrate;
  return await runMigration(migrationPath);
});
```

### Step 2: Update index.html

```html
<!-- Migration selector -->
<select id="migration-select">
  <option value="">Select a migration...</option>
  <!-- Options populated from loadMigrations() -->
</select>

<!-- Migration-specific UI -->
<div id="migration-ui"></div>

<!-- Start button -->
<button id="start-migration">Start Migration</button>
```

### Step 3: Update flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    migrations.url = "git+https://github.com/clearsky/clearsky/migrations";
  };

  outputs = { self, nixpkgs, migrations }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      
      # Load all migrations
      allMigrations = migrations.migrations.${system};
      
      # Build Electron app with migration support
      clearsky-app = pkgs.electronBuilder.buildElectronApplication {
        # ... existing config
        buildInputs = with pkgs; [
          # Include migration scripts
          (pkgs.buildEnv {
            name = "migrations";
            paths = builtins.values allMigrations;
          })
        ];
      };
    in {
      packages.x86_64-linux.default = clearsky-app;
    };
}
```

## Migration Interface

Each migration must provide:

```nix
{
  name = "Migration Name";
  source = "source-service";
  target = "target-service";
  description = "What this migration does";
  version = "1.0.0";
  migrate = derivation;  # The migration script
}
```

## Adding a New Migration

1. Create a new directory in `migrations/`
2. Add `flake.nix` with migration definition
3. Add `migrate.nix` with implementation
4. Test: `nix-build -A migrations.new-migration.migrate`
5. Run: `./result/bin/migrate`

## Testing

```bash
# List available migrations
nix eval --json .#migrations

# Build specific migration
nix-build -A migrations.google-photos-to-immich

# Run migration
./result/bin/migrate
```