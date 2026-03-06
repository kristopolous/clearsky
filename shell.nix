{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "clearsky-env";
  version = "1.0.0";

  buildInputs = with pkgs; [
    nodejs
    electron
    podman
    immich-go
    tailscale
  ];

  shellHook = ''
    echo "Clearsky development environment ready!"
    echo "Run 'npm install' to install Electron dependencies"
    echo "Then run 'npm start' to launch the app"
  '';
}