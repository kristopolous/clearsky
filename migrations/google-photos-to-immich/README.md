# Google Photos to Immich Migration

This migration moves data from Google Photos to Immich.

## Usage

```bash
# Build the migration
nix-build -A migrations.google-photos-to-immich.migrate

# Run the migration
./result/bin/migrate
```

## Flake Integration

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
      harnesses = migrations.harnesses.${system};
    in {
      migrations.${system}.google-photos-to-immich = {
        name = "Google Photos to Immich";
        source = "google-photos";
        target = "immich";
        description = "Migrate Google Photos exports to Immich";
        version = "1.0.0";
        
        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) download extract import-immich;
        };
      };
    };
}
```