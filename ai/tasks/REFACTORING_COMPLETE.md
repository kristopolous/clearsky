# Refactoring Complete: Migration Framework

## Summary

The Clearsky migration framework has been successfully refactored from a monolithic architecture to a modular, extensible system based on Nix flakes.

## What Was Changed

### 1. Fixed Migration Harnesses (`migrations/harnesses/`)

All harness files were cleaned up to remove markdown formatting and contain valid Nix code:

- **download.nix** - Downloads data from source services
- **extract.nix** - Extracts archived data (ZIP, TAR, etc.)
- **import-immich.nix** - Imports data to Immich
- **default.nix** - Exports all harnesses as a package set
- **registry.nix** - Harness registry (removed, consolidated into default.nix)

### 2. Updated Migration Registry (`migrations/registry.nix`)

Created a proper registry that loads all migrations and provides them as a package set:

```nix
{ pkgs }:

let
  harnesses = pkgs.callPackage ./harnesses {};

  migrations = {
    google-photos-to-immich = pkgs.callPackage ./google-photos-to-immich/migrate.nix {
      inherit (harnesses) download extract import-immich;
    };
  };
in {
  getMigrations = migrations;
  getMigrationNames = builtins.attrNames migrations;
}
```

### 3. Fixed Migration Flake (`migrations/flake.nix`)

Made the migrations directory a standalone Nix flake that can be used independently:

- Removed external dependencies that would cause circular references
- Uses local harnesses directly
- Exports migrations as packages

### 4. Updated Main Flake (`flake.nix`)

Simplified the main flake to:

- Use `flake-utils` for multi-system support
- Load migrations from local registry (no external git dependency)
- Provide clean devShell with helpful messages

### 5. Updated Electron App (`app/main.js`)

Refactored to support dynamic migration loading:

- `loadMigrations()` - Loads migrations from Nix registry
- `runMigration()` - Executes a migration by name
- IPC handlers for `get-migrations` and `run-migration`
- Graceful fallback when Nix is not available

### 6. Updated UI (`app/index.html`)

Added dynamic migration selector:

- Dropdown populated from loaded migrations
- Shows migration description when selected
- Supports both migration-based and manual flows
- Removed duplicate code

### 7. Simplified AppImage Build (`appimage.nix`)

Removed complex migration copying logic since migrations are now loaded dynamically at runtime.

## Architecture

### Before (Monolithic)

```
app/
├── main.js          # ALL migration logic hardcoded
├── index.html       # UI with hardcoded steps
└── package.json

flake.nix           # Single build, no modularity
```

### After (Modular)

```
app/
├── main.js          # Migration orchestrator (loads from registry)
├── index.html       # Dynamic UI based on migrations
└── package.json

migrations/
├── flake.nix        # Standalone migration flake
├── harnesses/       # Reusable components
│   ├── download.nix
│   ├── extract.nix
│   └── import-immich.nix
├── google-photos-to-immich/
│   ├── flake.nix
│   └── migrate.nix
└── registry.nix     # Load all migrations

flake.nix           # Integrates everything
```

## Benefits

1. **Extensibility** - Third parties can create migration flakes
2. **Maintainability** - Each migration is isolated
3. **Reusability** - Harnesses shared across migrations
4. **Testability** - Migrations can be tested independently
5. **Versioning** - Migrations versioned separately

## How to Add a New Migration

1. Create a new directory in `migrations/`
2. Add `flake.nix` with migration metadata
3. Add `migrate.nix` with implementation (use harnesses)
4. Update `registry.nix` to include the new migration
5. Test: Run the app and select the migration from the dropdown

## Example Migration

```nix
{
  description = "Google Photos to Immich migration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      harnesses = pkgs.callPackage ../harnesses {};
    in {
      packages.${system}.default = pkgs.callPackage ./migrate.nix {
        inherit (harnesses) download extract import-immich;
      };
    };
}
```

## Testing

### Without Nix (Development)

```bash
cd app
npm install
npm start
```

The app will use the fallback migration (Google Photos to Immich).

### With Nix (Production Build)

```bash
# Build AppImage
nix build

# Run the AppImage
./result/Clearsky-1.0.0.AppImage
```

## Files Modified

| File | Change |
|------|--------|
| `migrations/harnesses/default.nix` | Fixed syntax, removed markdown |
| `migrations/harnesses/download.nix` | Fixed syntax, removed markdown |
| `migrations/harnesses/extract.nix` | Fixed syntax, removed markdown |
| `migrations/harnesses/import-immich.nix` | Fixed syntax, removed markdown |
| `migrations/registry.nix` | Updated to use local harnesses |
| `migrations/flake.nix` | Made standalone, removed circular deps |
| `migrations/google-photos-to-immich/flake.nix` | Updated structure |
| `flake.nix` | Simplified, added flake-utils |
| `appimage.nix` | Removed complex migration copying |
| `app/main.js` | Added migration loading/execution |
| `app/index.html` | Added migration selector UI |

## Next Steps

1. **Test on target systems** - Ubuntu 22.04+, NixOS 24.11
2. **Add more migrations** - iCloud, Dropbox, etc.
3. **Enhance UI** - Better styling, more feedback
4. **Add migration validation** - Verify migrations meet interface
5. **Create migration gallery** - Discoverable registry of migrations

## Verification

All JavaScript syntax has been validated:
- ✅ `node --check app/main.js` passes
- ✅ npm install completes successfully
- ✅ Electron app structure is valid

The refactoring is complete and ready for testing!
