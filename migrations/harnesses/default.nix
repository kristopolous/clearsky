{ pkgs }:

let
  run-container = pkgs.callPackage ./run-container.nix {};
in {
  download = pkgs.callPackage ./download.nix {};
  extract = pkgs.callPackage ./extract.nix {};
  import-immich = pkgs.callPackage ./import-immich.nix { inherit run-container; };
  import-etherpad = pkgs.callPackage ./import-etherpad.nix { inherit run-container; };
  import-ghost = pkgs.callPackage ./import-ghost.nix {};
  google-photos-download = pkgs.callPackage ./google-photos-download.nix {};
  setup-nextcloud = pkgs.callPackage ./setup-nextcloud.nix { inherit run-container; };
  setup-owncloud = pkgs.callPackage ./setup-owncloud.nix { inherit run-container; };
  setup-homeassistant = pkgs.callPackage ./setup-homeassistant.nix { inherit run-container; };
  setup-ghost = pkgs.callPackage ./setup-ghost.nix { inherit run-container; };
  inherit run-container;
}
