# Migration Framework

## What This Is

A Nix-based migration system that allows Clearsky to support multiple data migration strategies through extensible, reproducible Nix flakes.

## How It Works

### Migration Flakes

Each migration is a self-contained Nix flake that defines:

- **Source**: Where data comes from (Google Photos, iCloud, etc.)
- **Target**: Where data goes (Immich, Nextcloud, etc.)
- **Steps**: Download, extract, import operations
- **Dependencies**: Tools needed (immich-go, podman, etc.)

### Migration Harnesses

Reusable components for common operations:

- **download**: Fetch data from source service
- **extract**: Unpack archives (ZIP, tar.gz, etc.)
- **import**: Move data to target service

### Registry

The migration registry loads all available migrations from configured flakes.

## Current State

### ✅ Completed

- Migration framework structure
- Harnesses (download, extract, import-immich)
- Example migration (Google Photos to Immich)
- Documentation
- Refactoring plan

### ⏳ In Progress

- Core refactoring (app/main.js)
- UI integration
- Migration loading

## Next Steps

1. Update `app/main.js` to load migrations dynamically
2. Update `app/index.html` to show migration selector
3. Test with existing migrations
4. Add more migrations (iCloud, Dropbox, etc.)

## For Contributors

See `migrations/HOWTO.md` for detailed instructions on creating new migrations.

## Documentation

- `migrations/README.md` - Overview
- `migrations/HOWTO.md` - Contribution guide
- `migrations/EXAMPLES.md` - Examples
- `migrations/HARNESSES.md` - Harnesses
- `migrations/migrations-flakes.md` - Technical details
- `tasks/refactor_migrations.md` - Refactoring plan
