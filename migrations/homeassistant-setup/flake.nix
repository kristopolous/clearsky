{
  description = "Home Assistant setup - Self-hosted home automation";

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
        inherit (harnesses) setup-homeassistant;
      };

      packages.${system}.homeassistant-setup = {
        name = "Home Assistant Setup";
        source = "new";
        target = "homeassistant";
        description = "Set up Home Assistant for self-hosted home automation and smart device control";
        version = "1.0.0";

        migrate = pkgs.callPackage ./migrate.nix {
          inherit (harnesses) setup-homeassistant;
        };
      };
    };
}
