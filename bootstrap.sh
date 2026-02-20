#!/usr/bin/env bash
# Bootstrap script for pranava-mk's Claude Code + Arch setup
# Usage: Run this after cloning claude-code-setup on a fresh machine
#
#   git clone git@github.com:pranava-mk/claude-code-setup.git ~/claude-code-setup
#   cd ~/claude-code-setup && bash bootstrap.sh

set -e

CLAUDE_SETUP_DIR="$HOME/claude-code-setup"
ARCHYDE_PREFS_DIR="$HOME/archyde-prefs"
ARCHYDE_PREFS_REPO="git@github.com:pranava-mk/archyde-prefs.git"

echo "==> Installing stow..."
sudo pacman -S --needed --noconfirm stow

echo "==> Cloning archyde-prefs..."
if [ ! -d "$ARCHYDE_PREFS_DIR" ]; then
    git clone "$ARCHYDE_PREFS_REPO" "$ARCHYDE_PREFS_DIR"
else
    echo "    archyde-prefs already exists, skipping clone"
fi

echo "==> Stowing claude-code-setup..."
cd "$CLAUDE_SETUP_DIR"
stow claude

echo "==> Stowing archyde-prefs packages..."
cd "$ARCHYDE_PREFS_DIR"
stow claude-global
stow system-issues
# stow hyprland  # uncomment after HyDE/Hyprland is installed

echo ""
echo "Done. Next steps:"
echo "  1. Install Claude Code: npm install -g @anthropic-ai/claude-code"
echo "  2. Run: claude"
echo "  3. Tell it: 'Read ~/.claude/CLAUDE.md and set up this machine'"
