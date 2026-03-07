{
  description = "Clearsky: No More Clouds - Desktop app for migrating data from cloud services to self-hosted alternatives";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Load migrations from local migrations directory
        migrationsRegistry = pkgs.callPackage ./migrations/registry.nix {
          inherit pkgs;
        };

        # Choose build based on platform
        clearskyPackage = if pkgs.stdenv.isLinux then
          pkgs.callPackage ./appimage.nix { inherit (migrationsRegistry) getMigrations; }
        else if pkgs.stdenv.isDarwin then
          pkgs.callPackage ./macos.nix { }
        else
          throw "Unsupported system: ${system}";
      in {
        packages.default = clearskyPackage;

        packages.appimage = if pkgs.stdenv.isLinux then clearskyPackage else null;
        packages.dmg = if pkgs.stdenv.isDarwin then clearskyPackage else null;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            electron
            npm
          ] ++ lib.optionals stdenv.isLinux [ podman immich-go tailscale ]
            ++ lib.optionals stdenv.isDarwin [ docker ];

          shellHook = ''
            echo "Clearsky development environment ready!"
            echo ""
            echo "System: ${system}"
            echo ""
            echo "Available migrations:"
            echo "  - google-photos-to-immich"
            echo "  - google-docs-to-etherpad"
            echo "  - substack-to-ghost"
            echo "  - medium-to-ghost"
            echo "  - nextcloud-setup"
            echo "  - owncloud-setup"
            echo "  - homeassistant-setup"
            echo "  - ghost-setup"
            echo ""
            if [ "${stdenv.isLinux}" = "1" ]; then
              echo "To build AppImage (Linux):"
              echo "  nix build"
            else
              echo "To build DMG (macOS):"
              echo "  nix build"
            fi
            echo ""
            echo "To run in dev mode:"
            echo "  cd app && npm install && npm start"
          '';
        };
      }
    );
}
