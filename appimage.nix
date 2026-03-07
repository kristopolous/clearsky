{ lib, stdenv, appimageTools, nodejs, electron, makeWrapper, podman, immich-go, tailscale, getMigrations ? {} }:

appimageTools.wrapAppImage {
  name = "clearsky";
  version = "1.0.0";

  src = ./app;

  extraPkgs = pkgs: [
    podman
    immich-go
    tailscale
  ];

  extraInstallCommands = ''
    mkdir -p $out/share/clearsky
    cp -r $src/* $out/share/clearsky/

    # Create launcher script
    makeWrapper ${nodejs}/bin/node $out/bin/clearsky \
      --add-flags "$out/share/clearsky/main.js" \
      --set NODE_PATH "$out/share/clearsky/node_modules" \
      --set PATH "${podman}/bin:${immich-go}/bin:${tailscale}/bin:$out/bin:$PATH"

    chmod +x $out/share/clearsky/run.sh
  '';

  meta = {
    description = "No More Clouds - Migrate your data to self-hosted services";
    longDescription = ''
      Clearsky is a desktop application for migrating data from cloud services
      to self-hosted, privacy-focused alternatives. Built with Nix for reproducible
      builds and Electron for cross-platform UI.

      Features:
      - Migration wizard for Google Photos, Drive, iCloud
      - Containerized services via Podman
      - Immich photo management
      - Tailscale remote access
      - Easy rollback
    '';
    homepage = "https://github.com/clearsky/clearsky";
    license = lib.licenses.mit;
    platforms = lib.optionals stdenv.isLinux [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "clearsky";
  };
}
