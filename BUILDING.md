# Clearsky
No More Clouds - Desktop app for migrating data from cloud services to self-hosted alternatives

## Build with Nix

```bash
# Build AppImage
nix build .#appimage

# Enter dev shell
nix-shell

# Run app
npm start
```

## Dependencies

- Node.js 18+
- Electron 33+
- Podman 4.0+
- immich-go
- tailscale

## License

MIT