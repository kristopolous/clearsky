# Migration Harnesses

Reusable components for building migrations.

## harnesses/

| File | Purpose |
|------|---------|
| `download.nix` | Download data from source service |
| `extract.nix` | Extract archived data |
| `import-immich.nix` | Import data to Immich |

## Using Harnesses

```nix
{ pkgs, harnesses }:

pkgs.callPackage ./migrate.nix {
  inherit (harnesses) download extract import-immich;
}
```

## Writing New Harnesses

1. Create `.nix` file in `harnesses/`
2. Use `pkgs.writeShellScriptBin` to create executable
3. Add to `registry.nix`
4. Test independently