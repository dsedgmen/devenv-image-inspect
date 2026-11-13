# Agent guide — devenv-image-inspect

## Purpose

Owns **container image inspect/export** for the devenv editor stack:

| Path | Role |
|------|------|
| `bin/devenv-image-inspect` | Podman-first CLI (`meta`, `history`, `fs`, `cat`, `export`) |
| `plugin/` + `autoload/` | Vim commands |
| `lua/image-inspect.lua` | Neovim module + `setup()` |
| `rpm/*` | Non-destructive packpath / vimfiles loaders |

Does **not** own AI keymaps, LSP, packaging Containerfiles, or registry pulls.

| Sibling | Role |
|---------|------|
| [devenv](https://github.com/dsedgmen/devenv) | Soft-discovers via `DEVENV_IMAGE_INSPECT_DIR` |
| [devenv-packager](https://github.com/dsedgmen/devenv-packager) | Stages via prepare-build-context |
| [devenv-ai-assistant](https://github.com/dsedgmen/devenv-ai-assistant) | Separate AI editor configs |

## Constraints

1. **CLI owns engine calls** — editors only shell out; do not reimplement inspect in Lua/Vim.
2. **Podman-first**, docker fallback; honor `DEVENV_IMAGE_ENGINE`.
3. **Stable names** — `devenv-image-inspect`, `require("image-inspect")`, commands `Image*`.
4. **No secrets in git.** Images stay local (user pulls first).
5. RPM must not overwrite `~/.vimrc` or `~/.config/nvim/init.lua`.

## Packaging

Mirror devenv-ai-assistant: `VERSION`, `scripts/rpm-version.sh`, `.copr/Makefile`,
`.packit.yaml`, workflows. Spec macros `devenv_fc_ver` / `devenv_fc_rel`.
RPMs: `devenv-image-inspect`, `-neovim`, `-vim`.

## Verify

- `bash -n bin/devenv-image-inspect install.sh`
- `devenv-image-inspect meta <local-image>`
- Vim `:ImageMeta` / Neovim `require("image-inspect").setup()`
- `./scripts/rpm-version.sh --shell`

Ask before: publishing releases, force-push, or skipping hooks.
