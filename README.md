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
makepkg -p packaging/arch/remote/PKGBUILD --printsrcinfo
makepkg -p packaging/arch/local/PKGBUILD --printsrcinfo
```

The installed Quickshell configuration is under
`/usr/share/argvus/control-panel/config/quickshell/argvus-control-panel/`.
The sidebar can be started with `qs -c argvus-control-panel`; the helper
scripts under `/usr/share/argvus/control-panel/sh/` support Waybar and
Hyprland integration.

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) — layout, checks, and releases
- [CONTRIBUTING.md](https://github.com/argvus/.github/blob/main/CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](https://github.com/argvus/.github/blob/main/SECURITY.md) — private vulnerability reports
- [Code of Conduct](https://github.com/argvus/.github/blob/main/policies/CODE_OF_CONDUCT.md) — community standards
- [AI usage policy](https://github.com/argvus/.github/blob/main/policies/IA_USAGE.md) — rules for AI-assisted contributions
- [src/usr/share/argvus/control-panel/docs/README.md](src/usr/share/argvus/control-panel/docs/README.md) — runtime integration

## License

SPDX: `GPL-3.0-only`. See [LICENSE](LICENSE).
