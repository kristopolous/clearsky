{ pkgs }:

let
  harnesses = pkgs.callPackage ./harnesses {};

  migrations = {
    google-photos-to-immich = pkgs.callPackage ./google-photos-to-immich/migrate.nix {
      inherit (harnesses) download extract import-immich;
    };
  };
in {
  getMigrations = migrations;
  getMigrationNames = builtins.attrNames migrations;
}
