{
  description = "ownCloud setup - Self-hosted file storage and collaboration";

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
        inherit (harnesses) setup-owncloud;
      };

      packages.${system}.owncloud-setup = {
        name = "ownCloud Setup";
        source = "new";
        target = "owncloud";
        description = "Set up ownCloud for self-hosted file storage, calendar, contacts, and collaboration";
        version = "1.0.0";

        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) setup-owncloud;
        };
      };
    };
}
