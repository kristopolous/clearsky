# Example Migrations

This directory contains example migration implementations.

## google-photos-to-immich/

Complete migration from Google Photos to Immich.

### Structure

```
google-photos-to-immich/
├── README.md              # Documentation
├── flake.nix              # Migration flake definition
└── migrate.nix            # Migration implementation
```

### Usage

```bash
# Build the migration
nix-build -A migrations.google-photos-to-immich

# Run the migration
./result/bin/migrate
```

### Adding More Examples

1. Create directory in `examples/`
2. Add `flake.nix` and `migrate.nix`
3. Document the migration
4. Submit a pull request