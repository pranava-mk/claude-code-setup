#!/usr/bin/env bash
# Bootstrap pranava-mk's Claude Code setup on a fresh machine, without an AI agent.
#
#   git clone https://github.com/pranava-mk/claude-code-setup.git ~/Projects/claude-code-setup
#   bash ~/Projects/claude-code-setup/bootstrap.sh
#
# Uses GNU Stow if it is installed (or pacman can install it). Otherwise copies.
# Existing ~/.claude files that would be replaced are backed up first.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="$(dirname "$SETUP_DIR")"
ARCHYDE_PREFS_DIR="$PROJECTS_DIR/archyde-prefs"
ARCHYDE_PREFS_REPO="https://github.com/pranava-mk/archyde-prefs.git"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"

backup() {
    # Move aside real files (not symlinks) that stow or cp would replace.
    local pkg_dir="$1" rel
    while IFS= read -r -d '' f; do
        rel="${f#"$pkg_dir"/}"
        if [ -e "$HOME/$rel" ] && [ ! -L "$HOME/$rel" ]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
            mv "$HOME/$rel" "$BACKUP_DIR/$rel"
            echo "    backed up ~/$rel"
        fi
    done < <(find "$pkg_dir" -type f -print0)
}

install_pkg() {
    # install_pkg <repo dir> <package>
    local repo="$1" pkg="$2"
    backup "$repo/$pkg"
    if [ "$USE_STOW" = 1 ]; then
        stow -d "$repo" -t "$HOME" "$pkg"
    else
        cp -r "$repo/$pkg/." "$HOME/"
    fi
}

echo "==> Checking for stow..."
USE_STOW=0
if command -v stow >/dev/null; then
    USE_STOW=1
elif command -v pacman >/dev/null; then
    sudo pacman -S --needed --noconfirm stow && USE_STOW=1
fi
[ "$USE_STOW" = 1 ] && echo "    using stow (symlinks)" || echo "    stow not available, copying files"

echo "==> Installing claude-code-setup (claude, ccstatusline)..."
install_pkg "$SETUP_DIR" claude
# ccstatusline reads ~/.config/ccstatusline, not ~/.claude, so it is its own package.
install_pkg "$SETUP_DIR" ccstatusline

echo "==> Fixing machine-specific paths in settings.json..."
SETTINGS="$HOME/.claude/settings.json"
if [ "$USE_STOW" = 1 ]; then
    echo "    settings.json is a symlink into the repo: edit paths there if your"
    echo "    home folder is not /home/cruxx or node is not the mise shim."
else
    sed -i "s|/home/cruxx|$HOME|g" "$SETTINGS"
    if NODE_BIN="$(command -v node)"; then
        sed -i "s|$HOME/.local/share/mise/shims/node|$NODE_BIN|" "$SETTINGS"
    fi
fi

echo "==> Installing status line dependencies..."
if command -v npm >/dev/null; then
    npm --prefix "$HOME/.claude/tools" ci
else
    echo "    npm not found: install Node.js, then run: npm --prefix ~/.claude/tools ci"
fi

echo "==> herdr session hook..."
if command -v herdr >/dev/null; then
    herdr integration install claude
else
    echo "    herdr not found, skipped (the hook exits quietly without it)"
fi

echo "==> Global CLAUDE.md from archyde-prefs..."
if [ ! -d "$ARCHYDE_PREFS_DIR" ]; then
    git clone "$ARCHYDE_PREFS_REPO" "$ARCHYDE_PREFS_DIR"
else
    echo "    archyde-prefs already exists, skipping clone"
fi
install_pkg "$ARCHYDE_PREFS_DIR" claude-global
install_pkg "$ARCHYDE_PREFS_DIR" archyde-issues-fixes

[ -d "$BACKUP_DIR" ] && echo "==> Backups of replaced files: $BACKUP_DIR"

echo ""
echo "Done. Next steps:"
echo "  1. Install Claude Code if needed: curl -fsSL https://claude.ai/install.sh | bash"
echo "  2. Run: claude"
echo "  3. The caveman plugin installs from its marketplace on first start."
