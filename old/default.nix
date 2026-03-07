# Migration Registry

```nix
{ pkgs }:

{
  download = pkgs.callPackage ./harnesses/download.nix {};
  extract = pkgs.callPackage ./harnesses/extract.nix {};
  import-immich = pkgs.callPackage ./harnesses/import-immich.nix {};
  google-photos-to-immich = pkgs.callPackage ./google-photos-to-immich/migrate.nix {
    inherit (self) download extract import-immich;
  };
}
```