# devenv-image-inspect

[![RPM](https://github.com/dsedgmen/devenv-image-inspect/actions/workflows/rpm.yml/badge.svg)](https://github.com/dsedgmen/devenv-image-inspect/actions/workflows/rpm.yml)
[![Security](https://github.com/dsedgmen/devenv-image-inspect/actions/workflows/security.yml/badge.svg)](https://github.com/dsedgmen/devenv-image-inspect/actions/workflows/security.yml)
[![Release](https://github.com/dsedgmen/devenv-image-inspect/actions/workflows/release.yml/badge.svg)](https://github.com/dsedgmen/devenv-image-inspect/actions/workflows/release.yml)
[![COPR](https://copr.fedorainfracloud.org/coprs/dsedgmen/devenv/package/devenv-image-inspect/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/dsedgmen/devenv/package/devenv-image-inspect/)
[![GitHub release](https://img.shields.io/github/v/release/dsedgmen/devenv-image-inspect?include_prereleases)](https://github.com/dsedgmen/devenv-image-inspect/releases)

Browse and export **container image** metadata, build history, and filesystem
from **Vim** and **Neovim**. Podman-first (docker fallback).

## Commands

| Command | Action |
|---------|--------|
| `:ImageInspect [ref]` | Overview buffer (meta + key shortcuts) |
| `:ImageMeta [ref]` | Config / labels / env (JSON) |
| `:ImageHistory [ref]` | Layer history + recovered Dockerfile |
| `:ImageFs [ref] [path]` | Filesystem browser (`<CR>` open, `-` parent) |
| `:ImageExport [ref] [outdir]` | Export `meta.json`, history, `rootfs/` |

CLI (same backend):

```bash
devenv-image-inspect meta quay.io/fedora/fedora:latest
devenv-image-inspect history fedora:latest
devenv-image-inspect fs fedora:latest /etc
devenv-image-inspect cat fedora:latest /etc/os-release
devenv-image-inspect export fedora:latest ./out
```

## Keymaps (default)

| Key | Action |
|-----|--------|
| `<Leader>ii` | ImageInspect |
| `<Leader>im` | ImageMeta |
| `<Leader>ih` | ImageHistory |
| `<Leader>if` | ImageFs |
| `<Leader>ie` | ImageExport |

Disable with `let g:image_inspect_map_keys = 0` (Vim) or
`require("image-inspect").setup({ map_keys = false })` (Neovim).

## Install (from git)

```bash
git clone https://github.com/dsedgmen/devenv-image-inspect.git
cd devenv-image-inspect
./install.sh
```

Neovim: add to init.lua:

```lua
require("image-inspect").setup()
```

Vim: plugin files under `~/.vim` load automatically.

## Install (Fedora COPR)

```bash
sudo dnf copr enable dsedgmen/devenv
sudo dnf install devenv-image-inspect-neovim   # and/or -vim
```

## Discovery for devenv / packaging

| Variable | Purpose |
|----------|---------|
| `DEVENV_IMAGE_INSPECT_DIR` | Path to this clone |
| `DEVENV_IMAGE_ENGINE` | Force `podman` or `docker` |

Or clone as sibling `../devenv-image-inspect` next to devenv / devenv-packager.

## Siblings

| Repo | Role |
|------|------|
| [devenv](https://github.com/dsedgmen/devenv) | Isolated AI sandboxes |
| [devenv-packager](https://github.com/dsedgmen/devenv-packager) | Stages this into images |
| [devenv-ai-assistant](https://github.com/dsedgmen/devenv-ai-assistant) | AI editor keymaps |
| [devenv-code-flowchart](https://github.com/dsedgmen/devenv-code-flowchart) | Offline call-graph |

Versioning / COPR / tags: [RELEASE.md](RELEASE.md). Agent guidance: [AGENTS.md](AGENTS.md).
