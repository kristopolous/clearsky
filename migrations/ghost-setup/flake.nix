{
  description = "Ghost setup - Self-hosted publishing platform";

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
        inherit (harnesses) setup-ghost;
      };

      packages.${system}.ghost-setup = {
        name = "Ghost Setup";
        source = "new";
        target = "ghost";
        description = "Set up Ghost for self-hosted blogging and publishing";
        version = "1.0.0";

        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) setup-ghost;
        };
      };
    };
}
