# How to Contribute Migrations

This guide explains how to create new migration strategies for Clearsky.

## Prerequisites

- Basic understanding of Nix flakes
- Familiarity with the migration you want to implement
- Access to a Linux system for testing

## Migration Types

### 1. Source-to-Target Migrations

Migrate data from a specific source service to a target service:

- Google Photos → Immich
- iCloud Photos → Immich
- Google Drive → Nextcloud

### 2. Export-Only Migrations

Generate export files without immediate import:

- Export Google Takeout bundle
- Prepare files for manual import

### 3. Import-Only Migrations

Import pre-exported data:

- Import ZIP files to Immich
- Import backup archives to target service

## Creating a Migration

### Step 1: Create the Migration Flake

```bash
mkdir -p migrations/google-photos-to-immich
cd migrations/google-photos-to-immich
```

Create `flake.nix`:

```nix
{
  description = "Google Photos to Immich migration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    clearsky-harnesses.url = "git+https://github.com/clearsky/clearsky/migrations/harnesses";
  };

  outputs = { self, nixpkgs, clearsky-harnesses }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      harnesses = clearsky-harnesses.migrations.${system};
    in {
      migrations.${system}.google-photos-to-immich = {
        name = "Google Photos to Immich";
        source = "google-photos";
        target = "immich";
        description = "Migrate Google Photos exports to Immich";
        version = "1.0.0";
        
        migrate = pkgs.writeShellScriptBin "migrate-google-photos" ''
          ${harnesses.download}/bin/download \
            --from "https://takeout.google.com" \
            --format "zip"
          
          ${harnesses.extract}/bin/extract \
            --input "$DOWNLOAD_OUTPUT" \
            --output "$EXTRACT_DIR"
          
          ${harnesses.import}/bin/import-immich \
            --input "$EXTRACT_DIR" \
            --host "http://localhost:2283"
        '';
      };
    };
}
```

### Step 2: Implement the Migration Script

Create `migrate.nix`:

```nix
{ pkgs, harnesses }:

pkgs.stdenv.mkDerivation {
  name = "google-photos-migration";
  version = "1.0.0";
  
  src = ./.;
  
  buildInputs = [
    pkgs.immich-go
    pkgs.unzip
  ];
  
  buildPhase = ''
    echo "Starting Google Photos migration..."
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    
    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e
    
    # Download Google Takeout
    # Extract ZIP files
    # Import to Immich
    
    echo "Migration complete!"
    EOF
    
    chmod +x $out/bin/migrate
  '';
}
```

### Step 3: Add to Clearsky

In the main Clearsky `flake.nix`, add your migration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    google-photos-migration.url = "git+https://github.com/clearsky/clearsky/migrations/google-photos-to-immich";
  };

  outputs = { self, nixpkgs, google-photos-migration }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      migrations.${system} = google-photos-migration.migrations.${system};
    };
}
```

## Migration Interface

Each migration must implement:

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Display name in UI |
| `source` | string | Source service identifier |
| `target` | string | Target service identifier |
| `description` | string | Detailed description |
| `version` | string | Migration version |
| `migrate` | derivation | Migration script/derivation |

## Testing

```bash
# Test the migration
nix-build -A migrations.google-photos-to-immich.migrate

# Run the migration
./result/bin/migrate
```

## Submitting

For the hackathon, submit migrations via pull request to the main repository.

In the future, migrations will be:
- Discoverable via a migration registry
- Versionable independently
- Installable via `nix profile install`