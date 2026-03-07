{
  description = "Medium to Ghost migration";

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
        inherit (harnesses) download extract import-ghost;
      };

      packages.${system}.medium-to-ghost = {
        name = "Medium to Ghost";
        source = "medium";
        target = "ghost";
        description = "Migrate Medium posts to Ghost (posts, images, metadata)";
        version = "1.0.0";

        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) download extract import-ghost;
        };
      };
    };
}
