# Refactoring Plan: Migrations Architecture

## Current State

### What Exists Now

1. **Monolithic Electron App** (`app/main.js`, `app/index.html`)
   - Contains all migration logic
   - Hardcoded Google Photos → Immich
   - No way to extend with new migrations

2. **Container Orchestration**
   - `startService()` function in main.js
   - `importToImmich()` function
   - All services hardcoded

3. **No Extension Points**
   - Can't add new migrations without code changes
   - No way for third parties to contribute

## Target State

### What We Want

1. **Migration Registry**
   - Load migrations from Nix flakes
   - Each migration is a self-contained flake
   - Migrations register themselves with metadata

2. **Migration Interface**
   - Standard interface all migrations implement
   - `source`, `target`, `name`, `migrate` attributes
   - Clear contract between Clearsky and migrations

3. **Migration Harnesses**
   - Reusable components (download, extract, import)
   - Shareable across migrations
   - Versioned independently

4. **UI Integration**
   - Migration selector in wizard
   - Dynamic UI based on migration metadata
   - Progress tracking per migration

## Implementation Steps

### Phase 1: Create Migration Infrastructure

1. **Create migrations directory structure**
   - `migrations/` - Migration flakes
   - `migrations/harnesses/` - Reusable components
   - `migrations/examples/` - Example migrations

2. **Define migration interface**
   - Standard attributes all migrations must provide
   - Nix type signatures for validation

3. **Create harnesses**
   - `download.nix` - Download data from source
   - `extract.nix` - Extract archives
   - `import.nix` - Import to target service

### Phase 2: Refactor Clearsky Core

1. **Separate migration logic from UI**
   - Move container orchestration to Nix
   - Keep Electron for UI only

2. **Add migration loader**
   - Load migrations from flakes
   - Parse migration metadata
   - Validate migration interface

3. **Update UI**
   - Show available migrations
   - Accept migration-specific parameters
   - Call migration via Nix

### Phase 3: Implement Current Migration as Flake

1. **Create google-photos-to-immich migration**
   - Extract from current monolithic code
   - Implement using harnesses
   - Test thoroughly

2. **Update flake.nix**
   - Load migrations
   - Pass migrations to Electron

### Phase 4: Test and Document

1. **Test migration system**
   - Load multiple migrations
   - Verify interface compliance
   - Test migration execution

2. **Update documentation**
   - Migration contributor guide
   - Example migrations
   - API documentation

## Code Changes

### New Files

```
migrations/
├── flake.nix           # Migration registry
├── harnesses/
│   ├── download.nix
│   ├── extract.nix
│   └── import.nix
├── examples/
│   └── google-photos-to-immich/
│       ├── flake.nix
│       └── migrate.nix
└── registry.nix        # Load all migrations
```

### Modified Files

```
app/
├── main.js             # Remove hardcoded migrations, add migration loader
├── index.html          # Add migration selector UI
└── package.json        # Add migration registry dependency

flake.nix             # Load and integrate migrations
```

## Migration Interface

```nix
{
  name = "Google Photos to Immich";
  source = "google-photos";
  target = "immich";
  description = "Migrate Google Photos exports to Immich";
  version = "1.0.0";
  
  migrate = {
    # Pre-migration checks
    prerequisites = [ podman immich-go ];
    
    # Download phase
    download = {
      source = "https://takeout.google.com";
      format = "zip";
    };
    
    # Extract phase
    extract = {
      input = "$DOWNLOAD_OUTPUT";
      output = "$EXTRACT_DIR";
    };
    
    # Import phase
    import = {
      input = "$EXTRACT_DIR";
      host = "http://localhost:2283";
      tool = immich-go;
    };
    
    # Post-migration cleanup
    cleanup = true;
  };
}
```

## Benefits of This Approach

1. **Extensibility**: Third parties can add migrations
2. **Maintainability**: Each migration is isolated
3. **Reusability**: Harnesses shared across migrations
4. **Testability**: Migrations can be tested independently
5. **Versioning**: Migrations versioned separately