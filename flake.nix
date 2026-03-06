{
  description = "Clearsky: No More Clouds - Desktop app for migrating data from cloud services to self-hosted alternatives";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      
      clearsky-appimage = pkgs.callPackage ./appimage.nix {};
    in {
      packages.x86_64-linux.default = clearsky-appimage;
      
      devShells.x86_64-linux.default = pkgs.mkShell {
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
          echo "To build AppImage:"
          echo "  nix build"
          echo ""
          echo "To run in dev mode:"
          echo "  cd app && npm install && npm start"
        '';
      };
    };
}