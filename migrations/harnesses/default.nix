{ pkgs }:

{
  download = pkgs.callPackage ./download.nix {};
  extract = pkgs.callPackage ./extract.nix {};
  import-immich = pkgs.callPackage ./import-immich.nix {};
  import-etherpad = pkgs.callPackage ./import-etherpad.nix {};
  google-photos-download = pkgs.callPackage ./google-photos-download.nix {};
  setup-nextcloud = pkgs.callPackage ./setup-nextcloud.nix {};
  setup-owncloud = pkgs.callPackage ./setup-owncloud.nix {};
  setup-homeassistant = pkgs.callPackage ./setup-homeassistant.nix {};
}
