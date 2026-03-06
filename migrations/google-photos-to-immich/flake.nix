{
  description = "Google Photos to Immich migration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      harnesses = pkgs.callPackage ../harnesses {};
    in {
      packages.${system}.default = pkgs.callPackage ./migrate.nix {
        inherit (harnesses) download extract import-immich;
      };

      packages.${system}.google-photos-to-immich = {
        name = "Google Photos to Immich";
        source = "google-photos";
        target = "immich";
        description = "Migrate Google Photos exports to Immich";
        version = "1.0.0";

        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) download extract import-immich;
        };
      };
    };
}
