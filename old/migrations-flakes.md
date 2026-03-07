# Migration Flakes

## Structure

```
migrations/
├── flake.nix              # Main migration registry
├── harnesses/
│   ├── download.nix
│   ├── extract.nix
│   └── import.nix
└── google-photos-to-immich/
    ├── flake.nix          # Migration definition
    └── migrate.nix        # Migration implementation
```

## Migration Flake Template

```nix
{
  description = "Google Photos to Immich migration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    harnesses.url = "git+https://github.com/clearsky/clearsky/migrations/harnesses";
  };

  outputs = { self, nixpkgs, harnesses }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      migrations.${system}.google-photos-to-immich = {
        name = "Google Photos to Immich";
        source = "google-photos";
        target = "immich";
        description = "Migrate Google Photos exports to Immich";
        version = "1.0.0";
        
        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) download extract import;
        };
      };
    };
}
```

## Migration Implementation

```nix
{ pkgs, download, extract, import }:

pkgs.stdenv.mkDerivation {
  name = "google-photos-migration";
  version = "1.0.0";
  
  buildInputs = [
    pkgs.curl
    pkgs.unzip
    pkgs.immich-go
  ];
  
  installPhase = ''
    mkdir -p $out/bin
    
    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e
    
    echo "Downloading Google Photos export..."
    ${download}/bin/download \
      --from "https://takeout.google.com" \
      --to "$TMPDIR"
    
    echo "Extracting export..."
    ${extract}/bin/extract \
      --input "$TMPDIR/export.zip" \
      --output "$TMPDIR/extracted"
    
    echo "Starting Immich..."
    podman run -d --name immich -p 2283:2283 \
      ghcr.io/immich-app/immich-server:latest
    
    echo "Importing to Immich..."
    ${import}/bin/import-immich \
      --input "$TMPDIR/extracted" \
      --host "http://localhost:2283"
    
    echo "Migration complete!"
    EOF
    
    chmod +x $out/bin/migrate
  '';
}
```

## Registry Integration

In `migrations/flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    google-photos = {
      url = "git+https://github.com/clearsky/clearsky/migrations/google-photos-to-immich";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, google-photos }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      
      # Load all migrations
      allMigrations = google-photos.migrations.${system};
    in {
      migrations.${system} = allMigrations;
    };
}
```

## Usage in Clearsky

```nix
# In main flake.nix
{
  inputs = {
    migrations.url = "git+https://github.com/clearsky/clearsky/migrations";
  };

  outputs = { self, nixpkgs, migrations }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      
      # Get migrations
      allMigrations = migrations.migrations.${system};
      
      # Build Electron app with migrations
      clearsky-app = pkgs.electronBuilder.buildElectronApplication {
        # ... other config
        buildInputs = with pkgs; [
          # Include migration scripts
          allMigrations.google-photos-to-immich.migrate
        ];
      };
    in {
      packages.x86_64-linux.default = clearsky-app;
    };
}
```

## Electron Integration

```javascript
// app/main.js
const { spawn } = require('child_process');
const path = require('path');

async function runMigration(migrationName) {
  const migrationPath = path.join(__dirname, '..', 'migrations', migrationName);
  
  return new Promise((resolve, reject) => {
    const child = spawn(migrationPath, [], {
      stdio: ['pipe', 'pipe', 'pipe']
    });
    
    let output = '';
    child.stdout.on('data', data => {
      output += data.toString();
      console.log(output);
    });
    
    child.on('close', code => {
      if (code === 0) {
        resolve(output);
      } else {
        reject(new Error(`Migration failed with code ${code}`));
      }
    });
  });
}

// UI calls this
ipcMain.handle('run-migration', async (event, { migration, params }) => {
  return await runMigration(migration);
});
```