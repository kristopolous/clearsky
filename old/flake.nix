{
  description = "Clearsky Migration Framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Load migration harnesses
      harnesses = pkgs.callPackage ./harnesses {};

      # Load all migrations
      migrations = {
        google-photos-to-immich = pkgs.callPackage ./google-photos-to-immich/migrate.nix {
          inherit (harnesses) download extract import-immich;
        };
      };
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "clearsky-migrations";
        paths = builtins.attrValues migrations;
      };

      packages.${system}.migrations = migrations;

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs
          electron
          podman
          immich-go
          tailscale
        ];

        shellHook = ''
          echo "Clearsky migration development environment ready!"
          echo "Run 'nix build' to build the AppImage with migrations"
        '';
      };
    };
}
