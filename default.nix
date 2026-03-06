{ pkgs ? import <nixpkgs> {} }:

let
  system = pkgs.system or "x86_64-linux";
  
  # Get the nixpkgs source for building
  nixpkgsSrc = pkgs.path;
  
  # Import appimageTools from nixpkgs
  appimageTools = import "${nixpkgsSrc}/pkgs/build-support/appimage" { inherit pkgs; };
  
  clearsky-appimage = pkgs.callPackage ./appimage.nix {};

in {
  packages.x86_64-linux.default = clearsky-appimage;
  
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
      echo "To build AppImage:"
      echo "  nix build"
      echo ""
      echo "To run in dev mode:"
      echo "  cd app && npm install && npm start"
    '';
  };
}