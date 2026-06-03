#!/usr/bin/env bash
#
# install.sh - Bootstrap dotfiles with GNU Stow
# Usage: bash install.sh [package ...]
#
# Without arguments, stows all packages.
# With arguments, stows only the named packages.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

PACKAGES=()
for d in */; do
    pkg="${d%/}"
    case "$pkg" in
        .git|bin) continue ;;
    esac
    # Only include non-empty dirs
    [ -n "$(find "$pkg" -type f 2>/dev/null)" ] && PACKAGES+=("$pkg")
done

stow_packages() {
    for pkg in "$@"; do
        echo "  stow $pkg"
        stow --adopt "$pkg" 2>/dev/null && echo "    ✓ linked" || echo "    ✗ failed"
    done
}

if [ $# -gt 0 ]; then
    echo "==> Stowing selected packages: $*"
    stow_packages "$@"
else
    echo "==> Stowing all packages: ${PACKAGES[*]}"
    stow_packages "${PACKAGES[@]}"
fi

echo ""
echo "==> Done! Restart shell or: source ~/.zshrc"
