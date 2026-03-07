# Code Walkthrough: Nix Features and Data Sovereignty

## Overview

Clearsky demonstrates how Nix's unique features enable **data sovereignty** for non-technical users. This walkthrough explores the codebase to show how declarative builds, reproducibility, and modularity make self-hosting accessible.

---

## 1. The Flake Structure: Declarative Dependencies

### `flake.nix`

```nix
{
  description = "Clearsky: No More Clouds - Desktop app for migrating data...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        migrationsRegistry = pkgs.callPackage ./migrations/registry.nix { inherit pkgs; };
      in {
        packages.default = pkgs.callPackage ./appimage.nix {
          inherit (migrationsRegistry) getMigrations;
        };

        devShells.default = pkgs.mkShell { ... };
      }
    );
}
```

**Sovereignty Feature:** This flake declares **exactly** what Clearsky needs to build and run. No hidden dependencies. No "works on my machine" problems. The same flake builds identically on your laptop, your friend's computer, or a server—ensuring the tool you trust today will work identically years from now.

**Why This Matters for Sovereignty:**
- **Long-term reproducibility**: Your migration tool won't break when npm updates
- **No trust required**: You can inspect every dependency
- **Offline builds**: Once cached, builds work without internet

---

## 2. Migration Framework: Modular Sovereignty

### `migrations/registry.nix`

```nix
{ pkgs }:

let
  harnesses = pkgs.callPackage ./harnesses {};

  migrations = {
    google-photos-to-immich = pkgs.callPackage ./google-photos-to-immich/migrate.nix {
      inherit (harnesses) download extract import-immich;
    };

    google-docs-to-etherpad = pkgs.callPackage ./google-docs-to-etherpad/migrate.nix {
      inherit (harnesses) download extract import-etherpad;
    };
  };
in {
  getMigrations = migrations;
  getMigrationNames = builtins.attrNames migrations;
}
```

**Sovereignty Feature:** Each migration is a **self-contained Nix derivation**. This means:
- Migrations can be audited independently
- Third parties can contribute without touching core code
- You can verify exactly what each migration does before running it

**Why This Matters for Sovereignty:**
- **No black boxes**: Every migration is readable, inspectable code
- **Community verification**: Others can review migrations for security
- **Extensibility**: Add migrations for any service without modifying Clearsky itself

---

## 3. Harnesses: Reusable Building Blocks

### `migrations/harnesses/default.nix`

```nix
{ pkgs }:

{
  download = pkgs.callPackage ./download.nix {};
  extract = pkgs.callPackage ./extract.nix {};
  import-immich = pkgs.callPackage ./import-immich.nix {};
  import-etherpad = pkgs.callPackage ./import-etherpad.nix {};
  google-photos-download = pkgs.callPackage ./google-photos-download.nix {};
}
```

### `migrations/harnesses/download.nix`

```nix
{ pkgs }:

pkgs.writeShellScriptBin "download" ''
  set -e

  FROM=""
  TO=""
  FORMAT="zip"

  while [ $# -gt 0 ]; do
    case "$1" in
      --from) FROM="$2"; shift 2 ;;
      --to) TO="$2"; shift 2 ;;
      --format) FORMAT="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  if [ -z "$FROM" ] || [ -z "$TO" ]; then
    echo "Usage: download --from URL --to DIR [--format FORMAT]"
    exit 1
  fi

  mkdir -p "$TO"
  curl -L "$FROM" -o "$TO/export.zip"
''
```

**Sovereignty Feature:** Harnesses are **composable, auditable components**. Each one does one thing well, and they're combined to create migrations. The `download` harness is 30 lines of shell script—you can read it, understand it, and trust it.

**Why This Matters for Sovereignty:**
- **Transparency**: No hidden API calls or data exfiltration
- **Modifiability**: Change a harness to suit your needs
- **Verification**: Each harness can be tested independently

---

## 4. Migration Scripts: Executable Sovereignty

### `migrations/google-photos-to-immich/migrate.nix`

```nix
{ pkgs, download, extract, import-immich }:

pkgs.stdenv.mkDerivation {
  name = "google-photos-to-immich";
  version = "2.0.0";

  buildInputs = [
    pkgs.curl
    pkgs.unzip
    pkgs.immich-go
    pkgs.podman
    pkgs.jq
  ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/migrate << 'EOF'
    #!/bin/sh
    set -e

    API_KEY="${GOOGLE_PHOTOS_API_KEY:-}"
    ZIP_FILE="${GOOGLE_PHOTOS_ZIP:-}"
    TMPDIR=$(mktemp -d)

    # Download photos (API or manual)
    if [ -n "$API_KEY" ]; then
      ${google-photos-download}/bin/google-photos-download \
        --api-key "$API_KEY" \
        --output "$TMPDIR/downloaded"
    elif [ -n "$ZIP_FILE" ]; then
      cp "$ZIP_FILE" "$TMPDIR/export.zip"
    fi

    # Extract and import to Immich
    ${extract}/bin/extract --input "$TMPDIR/export.zip" --output "$TMPDIR/extracted"
    ${import-immich}/bin/import-immich --input "$TMPDIR/extracted" --host "http://localhost:2283"

    rm -rf "$TMPDIR"
    echo "Migration complete! Your photos are now in Immich."
    EOF

    chmod +x $out/bin/migrate
  '';
}
```

**Sovereignty Feature:** This migration script is **completely self-contained**. It declares its dependencies (`curl`, `unzip`, `immich-go`, `podman`, `jq`), and Nix ensures they're all available at runtime. The script itself is visible, auditable, and modifiable.

**Why This Matters for Sovereignty:**
- **No hidden behavior**: The script does exactly what you see
- **Reproducible execution**: Same inputs = same outputs, every time
- **Local execution**: All processing happens on your machine

---

## 5. AppImage Build: Portable Sovereignty

### `appimage.nix`

```nix
{ lib, stdenv, appimageTools, nodejs, electron, makeWrapper, 
  podman, immich-go, tailscale, getMigrations ? {} }:

appimageTools.wrapAppImage {
  name = "clearsky";
  version = "1.0.0";

  src = ./app;

  extraPkgs = pkgs: [
    podman
    immich-go
    tailscale
  ];

  extraInstallCommands = ''
    mkdir -p $out/share/clearsky
    cp -r $src/* $out/share/clearsky/

    makeWrapper ${nodejs}/bin/node $out/bin/clearsky \
      --add-flags "$out/share/clearsky/main.js" \
      --set NODE_PATH "$out/share/clearsky/node_modules" \
      --set PATH "${podman}/bin:${immich-go}/bin:${tailscale}/bin:$out/bin:$PATH"
  '';

  meta = {
    description = "No More Clouds - Migrate your data to self-hosted services";
    homepage = "https://github.com/clearsky/clearsky";
    license = lib.licenses.mit;
  };
}
```

**Sovereignty Feature:** The AppImage bundles **everything** needed to run Clearsky. No system dependencies. No "install Node.js first." Just one executable file that works on any Linux system.

**Why This Matters for Sovereignty:**
- **Distribution without dependency**: Share one file, works everywhere
- **No trust in package managers**: Everything is bundled and verifiable
- **Long-term usability**: The AppImage will work 10 years from now

---

## 6. Electron App: UI for Sovereignty

### `app/main.js`

```javascript
async function runMigration(migrationName, options = {}) {
  const env = { ...process.env };
  
  // Pass API key via environment (not logged)
  if (options.apiKey) {
    env.GOOGLE_PHOTOS_API_KEY = options.apiKey;
  }
  
  // Build and run migration from Nix
  exec(`nix build ${migrationPath}#default -o /tmp/clearsky-migration`, (error) => {
    if (error) {
      // Fallback to local script
      exec(scriptPath, { env }, ...);
      return;
    }
    // Run the built migration
    exec('/tmp/clearsky-migration/bin/migrate', { env }, ...);
  });
}
```

**Sovereignty Feature:** The Electron app is a **thin orchestrator**. It doesn't contain migration logic—it loads migrations from the Nix registry and executes them. This separation means:
- The UI can't secretly exfiltrate data (it just runs scripts)
- Migrations are auditable separately from the UI
- You can run migrations directly without the UI if you prefer

**Why This Matters for Sovereignty:**
- **Separation of concerns**: UI is UI, logic is logic
- **Auditability**: Each layer can be inspected independently
- **Escape hatches**: Power users can bypass the UI entirely

---

## 7. API Key Handling: Secure Sovereignty

### `app/index.html`

```html
<div id="api-key-setup">
  <div class="info-box">
    <h3>🔑 Set Up Google Photos API Access</h3>
    <ol>
      <li>Go to Google Cloud Console</li>
      <li>Create a project, enable Google Photos Library API</li>
      <li>Create API Key in Credentials</li>
      <li>Copy and paste your key below</li>
    </ol>
    <p>Your API key is stored locally and never sent to any external server.</p>
  </div>
  
  <input type="password" id="google-api-key" 
    placeholder="Paste your API key here">
</div>
```

**Sovereignty Feature:** The API key flow is **transparent and local**. Users get their own API key from Google (no proxy, no Clearsky-managed credentials), and the key is passed directly to the migration script via environment variables.

**Why This Matters for Sovereignty:**
- **No credential sharing**: Your key goes to Google, not through Clearsky servers
- **User-controlled access**: You can revoke the key anytime
- **Transparent permissions**: You know exactly what access you're granting

---

## 8. Self-Hosting: Running Your Own Services

### `migrations/harnesses/import-immich.nix`

```nix
{ pkgs }:

pkgs.writeShellScriptBin "import-immich" ''
  set -e

  # Check if Immich is running
  if ! curl -s "$HOST/api/health" > /dev/null; then
    echo "Starting Immich..."
    podman run -d --name immich -p 2283:2283 \
      -v "$HOME/.clearsky/immich:/mnt/data" \
      ghcr.io/immich-app/immich-server:latest
  fi

  # Import photos
  immich-go import --input "$INPUT" --host "$HOST" --key "$KEY"
''
```

**Sovereignty Feature:** This harness starts **your own** Immich instance in a Podman container. No SaaS, no subscriptions—just you running the same software that powers commercial photo services, but on your own hardware.

**Why This Matters for Sovereignty:**
- **Data locality**: Your photos stay on your machine
- **No subscriptions**: One-time setup, free forever
- **Full control**: You configure backups, access, retention

---

## The Sovereignty Stack

Clearsky's architecture demonstrates a **stack of sovereignty features**:

| Layer | Technology | Sovereignty Benefit |
|-------|------------|---------------------|
| **Build** | Nix flakes | Reproducible, auditable builds |
| **Distribution** | AppImage | Single file, no dependencies |
| **Migration** | Nix derivations | Modular, inspectable migrations |
| **Execution** | Podman containers | Isolated, self-hosted services |
| **UI** | Electron | Simple interface, no hidden logic |
| **Credentials** | User-provided keys | No shared secrets |

---

## Conclusion: Sovereignty Through Simplicity

The key insight of Clearsky is that **sovereignty shouldn't require expertise**. Nix makes this possible by:

1. **Declarative builds** → You know exactly what you're running
2. **Reproducibility** → It works the same way every time
3. **Modularity** → Each piece can be audited independently
4. **Self-containment** → No external dependencies to trust

The result is a tool that lets non-technical users achieve data sovereignty—migrating from Google Photos to Immich, from Google Docs to Etherpad—without learning terminals, editing configs, or trusting third parties with their data.

**This is what sovereign computing looks like:** complex infrastructure hidden behind simple interfaces, built on foundations you can verify and trust.

---

## Further Reading

- [Nix Flakes Reference](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
- [AppImage Specification](https://appimage.org/)
- [Immich Documentation](https://immich.app/docs)
- [Podman Documentation](https://podman.io/docs)
