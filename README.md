# argvus-control-panel

Quickshell control panel for the ARGVUS desktop, providing the sidebar cards,
themes, and helper scripts used by the desktop session.

## Build and install

On Arch Linux or a compatible distribution:

```sh
sudo pacman -S --needed base-devel git shellcheck
make validate
make build
make install
```

`make build` creates a deterministic source archive in `build/artifacts/` and
the package in `build/dist/`. Package metadata can be inspected with:

```sh
makepkg -p packaging/arch/ci/PKGBUILD --printsrcinfo
makepkg -p packaging/arch/local/PKGBUILD --printsrcinfo
```

The installed Quickshell configuration is under
`/usr/share/argvus/control-panel/config/quickshell/argvus-control-panel/`.
The sidebar can be started with `qs -c argvus-control-panel`; the helper
scripts under `/usr/share/argvus/control-panel/sh/` support Waybar and
Hyprland integration.

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) — layout, checks, and releases
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](SECURITY.md) — private vulnerability reports
- [src/usr/share/argvus/control-panel/docs/README.md](src/usr/share/argvus/control-panel/docs/README.md) — runtime integration

## License

SPDX: `GPL-3.0-only`. See [LICENSE](LICENSE).
