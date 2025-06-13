#!/bin/bash
# Pocket IDE Quick Install Script
# Run this with: curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/install.sh | bash

set -e

echo "🚀 Pocket IDE Quick Installer"
echo "============================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check OS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script is designed for macOS"
    echo "   For other systems, please follow the manual setup in README.md"
    exit 1
fi

# Create local directory
POCKET_IDE_DIR="$HOME/.pocket-ide"
echo "📁 Creating Pocket IDE directory at $POCKET_IDE_DIR"
mkdir -p "$POCKET_IDE_DIR"

# Download scripts
echo "📥 Downloading scripts..."
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/start-pocket-ide.sh -o "$POCKET_IDE_DIR/start-pocket-ide.sh"
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/pocket-commands.sh -o "$POCKET_IDE_DIR/pocket-commands.sh"
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/configs/.tmux.conf -o "$HOME/.tmux.conf.pocket-ide"

# Make scripts executable
chmod +x "$POCKET_IDE_DIR/start-pocket-ide.sh"
chmod +x "$POCKET_IDE_DIR/pocket-commands.sh"

# Create symlinks
echo "🔗 Creating command shortcuts..."
mkdir -p "$HOME/.local/bin"
ln -sf "$POCKET_IDE_DIR/start-pocket-ide.sh" "$HOME/.local/bin/pocket-ide"
ln -sf "$POCKET_IDE_DIR/pocket-commands.sh" "$HOME/.local/bin/pocket"

# Add to PATH if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "📝 Adding ~/.local/bin to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    export PATH="$HOME/.local/bin:$PATH"
fi

# Check prerequisites
echo ""
echo "🔍 Checking prerequisites..."

if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found"
    echo "   Install it from: https://brew.sh"
    echo "   Then run: brew install tmux"
else
    if ! command -v tmux &> /dev/null; then
        echo "📦 Installing tmux..."
        brew install tmux
    else
        echo "✅ tmux is installed"
    fi
fi

if ! command -v claude &> /dev/null; then
    echo "⚠️  Claude Code not found"
    echo "   Download from: https://claude.ai/download"
    echo "   You can still use Pocket IDE, but you'll need to start Claude manually"
else
    echo "✅ Claude Code is installed"
fi

# Backup existing tmux config if it exists
if [ -f "$HOME/.tmux.conf" ]; then
    echo "📋 Backing up existing tmux config..."
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup"
fi

# Apply tmux config
echo "⚙️  Setting up tmux configuration..."
cp "$HOME/.tmux.conf.pocket-ide" "$HOME/.tmux.conf"

echo ""
echo -e "${GREEN}✅ Pocket IDE installed successfully!${NC}"
echo ""
echo -e "${BLUE}🏠 LOCAL NETWORK SETUP COMPLETE${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎯 Quick Start:"
echo "   pocket-ide start    # Start or attach to session"
echo "   pocket status       # Check Claude status"
echo "   pocket run 'cmd'    # Send command to Claude"
echo ""
echo "📱 Mobile Setup (Local Network Only):"
echo "   1. Download Termius on your phone"
echo "   2. Find your Mac's IP: ipconfig getifaddr en0"
echo "   3. Add your Mac as a host in Termius"
echo "   4. Connect and run: tmux attach -t vibecode"
echo ""
echo -e "${YELLOW}🌐 WANT TO ACCESS FROM ANYWHERE?${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Enable remote access with Tailscale (recommended):"
echo ""
echo -e "${GREEN}curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/tailscale-upgrade.sh | bash${NC}"
echo ""
echo "This adds:"
echo "  • Access from anywhere (coffee shops, cellular, etc)"
echo "  • Ultra-short commands (s, r, d, etc)"
echo "  • Better mobile experience"
echo "  • Secure encrypted connections"
echo ""
echo "📚 Full documentation: https://github.com/H0BB5/pocket-ide"
echo ""
echo -e "${YELLOW}Don't forget to reload your shell:${NC}"
echo "   source ~/.zshrc"