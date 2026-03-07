# Migration Harnesses Registry

```nix
{ pkgs }:

{
  download = pkgs.callPackage ./download.nix {};
  extract = pkgs.callPackage ./extract.nix {};
  import-immich = pkgs.callPackage ./import-immich.nix {};
}
```