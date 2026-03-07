{
  description = "Substack to Ghost migration";

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

      packages.${system}.substack-to-ghost = {
        name = "Substack to Ghost";
        source = "substack";
        target = "ghost";
        description = "Migrate Substack publications to Ghost (posts, subscribers, newsletters)";
        version = "1.0.0";

        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) download extract import-ghost;
        };
      };
    };
}
