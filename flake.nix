{
  description = "Clearsky: No More Clouds - Desktop app for migrating data from cloud services to self-hosted alternatives";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Load migrations from local migrations directory
        migrationsRegistry = pkgs.callPackage ./migrations/registry.nix {
          inherit pkgs;
        };
      in {
        packages.default = pkgs.callPackage ./appimage.nix {
          inherit (migrationsRegistry) getMigrations;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            electron
            podman
            immich-go
            tailscale
            npm
          ];

          shellHook = ''
            echo "Clearsky development environment ready!"
            echo ""
            echo "Available migrations:"
            echo "  - google-photos-to-immich"
            echo ""
            echo "To build AppImage:"
            echo "  nix build"
            echo ""
            echo "To run in dev mode:"
            echo "  cd app && npm install && npm start"
          '';
        };
      }
    );
}
