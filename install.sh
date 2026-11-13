#!/usr/bin/env bash
# Install devenv-image-inspect CLI + Vim/Neovim frontends.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${1:-$HOME/.local/bin}"

echo "================================================"
echo "Installing devenv-image-inspect"
echo "================================================"
echo ""

mkdir -p "$BIN_DIR"
install -m 0755 "$SCRIPT_DIR/bin/devenv-image-inspect" "$BIN_DIR/devenv-image-inspect"

mkdir -p "$HOME/.vim/plugin" "$HOME/.vim/autoload"
install -m 0644 "$SCRIPT_DIR/plugin/image-inspect.vim" "$HOME/.vim/plugin/image-inspect.vim"
install -m 0644 "$SCRIPT_DIR/autoload/image_inspect.vim" "$HOME/.vim/autoload/image_inspect.vim"

mkdir -p "$HOME/.config/nvim/lua"
install -m 0644 "$SCRIPT_DIR/lua/image-inspect.lua" "$HOME/.config/nvim/lua/image-inspect.lua"

echo "Installed:"
echo "  - $BIN_DIR/devenv-image-inspect"
echo "  - ~/.vim/plugin/image-inspect.vim"
echo "  - ~/.vim/autoload/image_inspect.vim"
echo "  - ~/.config/nvim/lua/image-inspect.lua"
echo ""
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
  echo "Add to your shell profile:"
  echo "  export PATH=\"$BIN_DIR:\$PATH\""
  echo ""
fi
echo "Neovim: require(\"image-inspect\").setup()"
echo "Vim:    commands ImageInspect / ImageMeta / ImageHistory / ImageFs / ImageExport"
echo "Keys:   <Leader>ii im ih if ie (unless g:image_inspect_map_keys = 0)"
echo ""
echo "Requires: podman (preferred) or docker"
echo ""
