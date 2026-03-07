{ pkgs }:

let
  harnesses = pkgs.callPackage ./harnesses {};

  migrations = {
    google-photos-to-immich = pkgs.callPackage ./google-photos-to-immich/migrate.nix {
      inherit (harnesses) download extract import-immich google-photos-download;
    };

    google-docs-to-etherpad = pkgs.callPackage ./google-docs-to-etherpad/migrate.nix {
      inherit (harnesses) download extract import-etherpad;
    };

    nextcloud-setup = pkgs.callPackage ./nextcloud-setup/migrate.nix {
      inherit (harnesses) setup-nextcloud;
    };

    owncloud-setup = pkgs.callPackage ./owncloud-setup/migrate.nix {
      inherit (harnesses) setup-owncloud;
    };

    homeassistant-setup = pkgs.callPackage ./homeassistant-setup/migrate.nix {
      inherit (harnesses) setup-homeassistant;
    };

    ghost-setup = pkgs.callPackage ./ghost-setup/migrate.nix {
      inherit (harnesses) setup-ghost;
    };

    substack-to-ghost = pkgs.callPackage ./substack-to-ghost/migrate.nix {
      inherit (harnesses) download extract import-ghost;
    };

    medium-to-ghost = pkgs.callPackage ./medium-to-ghost/migrate.nix {
      inherit (harnesses) download extract import-ghost;
    };
  };
in {
  getMigrations = migrations;
  getMigrationNames = builtins.attrNames migrations;
}
