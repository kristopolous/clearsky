# Pull Request: Migration Framework

## Summary

This PR introduces a flexible, Nix-based migration framework for Clearsky, allowing third-party contributions and extensible data migration strategies without modifying core code.

## Problem Solved

Previously, Clearsky had hardcoded migration logic in `app/main.js`. This made it difficult to:

- Add new migrations without code changes
- Test migrations independently
- Allow third-party contributions
- Maintain reproducible builds

## Solution

The migration framework uses Nix flakes to define migrations as self-contained, reproducible units. Each migration:

1. Is a separate Nix flake with standard interface
2. Uses reusable harnesses for common operations
3. Can be developed and tested independently
4. Integrates with Clearsky via the migration registry

## Changes

### New Files

- `migrations/README.md` - Overview of migration system
- `migrations/HOWTO.md` - Guide for contributing new migrations
- `migrations/EXAMPLES.md` - Example migration implementations
- `migrations/HARNESSES.md` - Reusable migration components
- `migrations/migrations-flakes.md` - Technical documentation
- `migrations/harnesses/download.nix` - Download harness
- `migrations/harnesses/extract.nix` - Extract harness
- `migrations/harnesses/import-immich.nix` - Import harness
- `migrations/google-photos-to-immich/` - Example migration
- `tasks/refactor_migrations.md` - Refactoring plan

### Modified Files

- `app/main.js` - Remove hardcoded migration logic, add migration loader
- `app/index.html` - Add migration selector UI
- `flake.nix` - Integrate migration flakes
- `default.nix` - Update to support migration system

## Design Decisions

1. **Nix-based**: Migrations are Nix flakes for reproducibility
2. **Harnesses**: Reusable components (download, extract, import)
3. **Standard Interface**: All migrations implement same attributes
4. **Self-Contained**: Each migration is a separate flake

## Testing

- [ ] Test migration loading
- [ ] Test migration execution
- [ ] Test multiple migrations
- [ ] Test migration registration

## Future Work

- [ ] Migration registry (online discovery)
- [ ] Versioned migrations
- [ ] Migration dependencies
- [ ] Migration testing framework