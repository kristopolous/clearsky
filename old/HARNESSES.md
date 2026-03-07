# Migration Harnesses

## What Are Harnesses?

Harnesses are reusable Nix expressions that provide common migration operations:

- **download**: Fetch data from source service
- **extract**: Unpack archives (ZIP, tar.gz, etc.)
- **import-immich**: Import data to Immich

## Why Use Harnesses?

1. **Reusability**: Same code across multiple migrations
2. **Maintainability**: Fix once,受益 across all migrations
3. **Consistency**: Same behavior for all migrations
4. **Testing**: Test harnesses independently

## Available Harnesses

### download.nix

Downloads data from a source service.

**Usage:**
```bash
download --from URL --to DIR [--format FORMAT]
```

**Example:**
```bash
download --from "https://takeout.google.com" --to "/tmp/data" --format "zip"
```

### extract.nix

Extracts archived data.

**Usage:**
```bash
extract --input FILE --output DIR [--format FORMAT]
```

**Supported formats:** zip, tar, tar.gz, tgz, tar.bz2

### import-immich.nix

Imports data to Immich service.

**Usage:**
```bash
import-immich --input DIR --host URL [--key KEY]
```

## Writing New Harnesses

1. Create a new `.nix` file in `harnesses/`
2. Use `pkgs.writeShellScriptBin` to create executable
3. Document the interface
4. Add to `registry.nix`

## Example: Custom Harness

```nix
{ pkgs }:

pkgs.writeShellScriptBin "my-harness" ''
  # Usage: my-harness --input FILE --output DIR
  while [ $# -gt 0 ]; do
    case "$1" in
      --input)
        INPUT="$2"
        shift 2
        ;;
      --output)
        OUTPUT="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done
  
  # Your implementation here
  echo "Processing $INPUT -> $OUTPUT"
'';
```

## Integration with Migrations

```nix
{ pkgs, harnesses }:

pkgs.callPackage ./migrate.nix {
  inherit (harnesses) download extract import-immich;
}
```

## Testing Harnesses

```bash
# Test download harness
nix-build -E 'with import <nixpkgs> {}; callPackage ./harnesses/download.nix {}'

# Test extract harness
nix-build -E 'with import <nixpkgs> {}; callPackage ./harnesses/extract.nix {}'

# Test import-immich harness
nix-build -E 'with import <nixpkgs> {}; callPackage ./harnesses/import-immich.nix {}'
```