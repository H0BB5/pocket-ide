#!/bin/bash
# Tailscale Upgrade Script for Pocket IDE
# This script enhances Pocket IDE with Tailscale-aware features

set -e

echo "🚀 Pocket IDE Tailscale Upgrade"
echo "=============================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Tailscale is installed
if ! command -v tailscale &> /dev/null; then
    echo -e "${RED}❌ Tailscale not found${NC}"
    echo "Install it first with: brew install tailscale"
    exit 1
fi

# Get Tailscale status
TS_STATUS=$(tailscale status --json 2>/dev/null || echo "{}")
if [ "$TS_STATUS" = "{}" ]; then
    echo -e "${YELLOW}⚠️  Tailscale not running${NC}"
    echo "Start it with: sudo tailscale up"
    exit 1
fi

# Get Tailscale hostname
TS_HOSTNAME=$(tailscale status --json | grep -o '"Self":{[^}]*}' | grep -o '"HostName":"[^"]*"' | cut -d'"' -f4)
if [ -z "$TS_HOSTNAME" ]; then
    TS_HOSTNAME=$(hostname -s)
fi

echo -e "${GREEN}✅ Tailscale detected${NC}"
echo "   Hostname: $TS_HOSTNAME"

# Create enhanced directory structure
POCKET_IDE_DIR="$HOME/.pocket-ide"
mkdir -p "$POCKET_IDE_DIR/bin"
mkdir -p "$POCKET_IDE_DIR/config"

# Download enhanced scripts
echo -e "\n📥 Downloading enhanced scripts..."

# Create the ultra-short command wrapper
cat > "$POCKET_IDE_DIR/bin/pocket-quick.sh" << 'EOF'
#!/bin/bash
# Pocket IDE Quick Commands - Ultra-short for mobile

SESSION="vibecode"

# Auto-create session if needed
if ! tmux has-session -t $SESSION 2>/dev/null; then
    $HOME/.pocket-ide/start-pocket-ide.sh > /dev/null 2>&1
fi

# Command shortcuts
case "${1:-d}" in
    # Status commands
    s)  # Status
        tmux capture-pane -t $SESSION:0.0 -p | tail -20
        ;;
    l)  # Last 10 lines
        tmux capture-pane -t $SESSION:0.0 -p | tail -10
        ;;
    ll) # Last 50 lines
        tmux capture-pane -t $SESSION:0.0 -p | tail -50
        ;;
    
    # Action commands
    r)  # Run
        shift
        tmux send-keys -t $SESSION:0.0 "$*" Enter
        echo "✅ Sent: $*"
        ;;
    c)  # Clear
        tmux send-keys -t $SESSION:0.0 "clear" Enter
        ;;
    k)  # Kill current process
        tmux send-keys -t $SESSION:0.0 C-c
        echo "🛑 Interrupted"
        ;;
    rs) # Restart Claude
        tmux send-keys -t $SESSION:0.0 C-c
        sleep 0.5
        tmux send-keys -t $SESSION:0.0 "claude" Enter
        echo "🔄 Restarted Claude"
        ;;
    
    # Navigation
    1)  # Claude pane
        tmux select-pane -t $SESSION:0.0
        tmux attach-session -t $SESSION
        ;;
    2)  # Terminal pane
        tmux select-pane -t $SESSION:0.1
        tmux attach-session -t $SESSION
        ;;
    3)  # Monitor window
        tmux select-window -t $SESSION:1
        tmux attach-session -t $SESSION
        ;;
    
    # Dashboard view
    d)  # Dashboard
        echo "📊 POCKET IDE DASHBOARD"
        echo "====================="
        echo ""
        echo "🤖 Claude Status:"
        if tmux capture-pane -t $SESSION:0.0 -p 2>/dev/null | tail -1 | grep -q "claude>"; then
            echo "   ✅ Ready for input"
        else
            echo "   ⏳ Working..."
            echo ""
            echo "Last output:"
            tmux capture-pane -t $SESSION:0.0 -p | tail -3 | sed 's/^/   /'
        fi
        echo ""
        echo "📁 Current Directory:"
        tmux capture-pane -t $SESSION:0.1 -p | grep -E "^[~/].*\$" | tail -1 | sed 's/\$.*//' | sed 's/^/   /'
        echo ""
        echo "Quick Commands:"
        echo "   s=status  r=run  c=clear  k=kill"
        echo "   1=claude  2=term  3=monitor  h=help"
        ;;
    
    # Help
    h)  # Help
        echo "🚀 POCKET IDE QUICK COMMANDS"
        echo ""
        echo "STATUS            ACTION            NAV"
        echo "s  - status       r <cmd> - run     1 - claude"
        echo "l  - last 10      c - clear         2 - terminal"
        echo "ll - last 50      k - kill process  3 - monitor"
        echo "d  - dashboard    rs - restart      "
        echo ""
        echo "Example: r 'create a hello world'"
        ;;
    
    # Default to dashboard
    *)
        $0 d
        ;;
esac
EOF

chmod +x "$POCKET_IDE_DIR/bin/pocket-quick.sh"

# Create SSH config generator
cat > "$POCKET_IDE_DIR/bin/generate-ssh-config.sh" << EOF
#!/bin/bash
# Generate SSH config for one-tap connection

echo "Host pocket"
echo "    HostName $TS_HOSTNAME"
echo "    User $USER"
echo "    RequestTTY yes"
echo "    RemoteCommand $HOME/.pocket-ide/bin/pocket-quick.sh d && exec bash"
echo ""
echo "# Copy the above to ~/.ssh/config on your phone"
EOF

chmod +x "$POCKET_IDE_DIR/bin/generate-ssh-config.sh"

# Create auto-attach script
cat > "$POCKET_IDE_DIR/bin/auto-attach.sh" << 'EOF'
#!/bin/bash
# Auto-attach to tmux session or create if needed

SESSION="vibecode"

if tmux has-session -t $SESSION 2>/dev/null; then
    exec tmux attach-session -t $SESSION
else
    exec $HOME/.pocket-ide/start-pocket-ide.sh
fi
EOF

chmod +x "$POCKET_IDE_DIR/bin/auto-attach.sh"

# Update PATH and create aliases
echo -e "\n📝 Setting up shortcuts..."

# Create single-letter aliases
for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$shell_rc" ]; then
        # Remove old aliases if they exist
        sed -i.bak '/# Pocket IDE shortcuts/,/# End Pocket IDE shortcuts/d' "$shell_rc"
        
        # Add new aliases
        cat >> "$shell_rc" << 'EOF'

# Pocket IDE shortcuts
alias s='~/.pocket-ide/bin/pocket-quick.sh s'
alias l='~/.pocket-ide/bin/pocket-quick.sh l'
alias ll='~/.pocket-ide/bin/pocket-quick.sh ll'
alias r='~/.pocket-ide/bin/pocket-quick.sh r'
alias c='~/.pocket-ide/bin/pocket-quick.sh c'
alias k='~/.pocket-ide/bin/pocket-quick.sh k'
alias rs='~/.pocket-ide/bin/pocket-quick.sh rs'
alias d='~/.pocket-ide/bin/pocket-quick.sh d'
alias h='~/.pocket-ide/bin/pocket-quick.sh h'

# Number shortcuts for pane switching
alias 1='~/.pocket-ide/bin/pocket-quick.sh 1'
alias 2='~/.pocket-ide/bin/pocket-quick.sh 2'
alias 3='~/.pocket-ide/bin/pocket-quick.sh 3'

# Auto-attach alias
alias pocket='~/.pocket-ide/bin/auto-attach.sh'
# End Pocket IDE shortcuts
EOF
    fi
done

# Create Tailscale-aware config
cat > "$POCKET_IDE_DIR/config/tailscale.conf" << EOF
# Tailscale configuration for Pocket IDE
TAILSCALE_HOSTNAME="$TS_HOSTNAME"
TAILSCALE_ENABLED=true
AUTO_ATTACH_ON_SSH=true
EOF

# Show SSH config for mobile
echo -e "\n${GREEN}✅ Tailscale upgrade complete!${NC}"
echo ""
echo "📱 For one-tap mobile access, add this to Termius:"
echo "   Host: $TS_HOSTNAME"
echo "   Username: $USER"
echo ""
echo "Or for advanced users, add this SSH config:"
echo "----------------------------------------"
"$POCKET_IDE_DIR/bin/generate-ssh-config.sh"
echo "----------------------------------------"
echo ""
echo "🎯 Ultra-short commands now available:"
echo "   s = status     r = run command"
echo "   d = dashboard  h = help"
echo ""
echo "Reload your shell: source ~/.zshrc"