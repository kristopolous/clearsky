{
  description = "Google Docs to Etherpad migration";

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
        inherit (harnesses) download extract import-etherpad;
      };

      packages.${system}.google-docs-to-etherpad = {
        name = "Google Docs to Etherpad";
        source = "google-docs";
        target = "etherpad";
        description = "Migrate Google Docs exports to Etherpad for collaborative editing";
        version = "1.0.0";

        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) download extract import-etherpad;
        };
      };
    };
}
