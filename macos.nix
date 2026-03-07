{ lib, stdenv, nodePackages, electron, makeWrapper, podman, immich-go, tailscale }:

stdenv.mkDerivation {
  name = "clearsky";
  version = "1.0.0";

  src = ./app;

  buildInputs = [
    nodePackages.npm
    electron
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  buildPhase = ''
    cd $src
    npm install
    npm run build:mac
  '';

  installPhase = ''
    mkdir -p $out/Applications/Clearsky.app
    cp -r $src/dist/mac/Clearsky.app/* $out/Applications/Clearsky.app/
    
    # Create wrapper script
    makeWrapper ${electron}/bin/electron $out/bin/clearsky \
      --add-flags "$out/Applications/Clearsky.app/Contents/Resources/app" \
      --set PATH "${podman}/bin:${immich-go}/bin:${tailscale}/bin:$out/bin:$PATH"
  '';

  meta = {
    description = "No More Clouds - Migrate your data to self-hosted services";
    longDescription = ''
      Clearsky is a desktop application for migrating data from cloud services
      to self-hosted, privacy-focused alternatives. Built with Nix for reproducible
      builds and Electron for cross-platform UI.

      Features:
      - Migration wizard for Google Photos, Drive, iCloud
      - Containerized services via Podman/Docker
      - Immich photo management
      - Tailscale remote access
      - Easy rollback
    '';
    homepage = "https://github.com/clearsky/clearsky";
    license = lib.licenses.mit;
    platforms = lib.optionals stdenv.isDarwin [ "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "clearsky";
  };
}
