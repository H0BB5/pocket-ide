#!/bin/bash
# Tailscale Upgrade Script for Pocket IDE
# This script enhances Pocket IDE with Tailscale-aware features

set -e

# Fix terminal environment
export TERM="${TERM:-xterm-256color}"

# More robust color detection
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    ncolors=$(tput colors 2>/dev/null || echo 0)
    if [[ -n "$ncolors" ]] && [[ "$ncolors" -ge 8 ]]; then
        bold="$(tput bold 2>/dev/null || echo '')"
        normal="$(tput sgr0 2>/dev/null || echo '')"
        red="$(tput setaf 1 2>/dev/null || echo '')"
        green="$(tput setaf 2 2>/dev/null || echo '')"
        yellow="$(tput setaf 3 2>/dev/null || echo '')"
        blue="$(tput setaf 4 2>/dev/null || echo '')"
    else
        # No color support
        bold=""
        normal=""
        red=""
        green=""
        yellow=""
        blue=""
    fi
else
    # No color support
    bold=""
    normal=""
    red=""
    green=""
    yellow=""
    blue=""
fi

# Clean any stray escape sequences
printf '\033[0m' 2>/dev/null || true

# Simple banner without Unicode
echo ""
echo "${bold}Pocket IDE Tailscale Upgrade${normal}"
echo "============================"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Tailscale GUI app is installed
check_tailscale_app() {
    if [ -d "/Applications/Tailscale.app" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if Tailscale is running
check_tailscale_running() {
    if tailscale status >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

echo "Checking Tailscale installation..."
echo ""

# Step 1: Check if Tailscale is properly installed and running
if ! check_tailscale_running; then
    echo "${yellow}! Tailscale is not running${normal}"
    
    # Check if Tailscale CLI is installed but not the app
    if command_exists tailscale && ! check_tailscale_app; then
        echo "${yellow}Found Tailscale CLI but not the GUI app${normal}"
        echo "On macOS, you need the Tailscale app for the service to run."
        echo ""
        echo "${blue}Installing Tailscale app...${normal}"
        
        if command_exists brew; then
            brew install --cask tailscale || {
                echo "${red}Failed to install Tailscale${normal}"
                echo "Please install manually from: https://tailscale.com/download"
                exit 1
            }
        else
            echo "${red}Homebrew not found${normal}"
            echo "Please install Tailscale from: https://tailscale.com/download"
            exit 1
        fi
    elif ! command_exists tailscale; then
        # No Tailscale at all
        echo "${yellow}Tailscale not found${normal}"
        echo ""
        echo "${blue}Installing Tailscale...${normal}"
        
        if command_exists brew; then
            # Install both CLI and GUI
            brew install tailscale
            brew install --cask tailscale
        else
            echo "${red}Homebrew not found${normal}"
            echo "Please install Tailscale from: https://tailscale.com/download"
            exit 1
        fi
    fi
    
    # Launch Tailscale app
    echo ""
    echo "${blue}Launching Tailscale app...${normal}"
    open -a Tailscale 2>/dev/null || {
        echo "${red}Could not launch Tailscale app${normal}"
        echo "Please open Tailscale manually from Applications"
        exit 1
    }
    
    echo ""
    echo "${bold}${yellow}IMPORTANT: Tailscale Setup Required${normal}"
    echo "------------------------------------"
    echo "1. Look for the Tailscale icon in your menu bar (top right)"
    echo "2. Click it and select 'Log in...'"
    echo "3. Sign in with Google, Microsoft, GitHub, or email"
    echo "4. Once connected, you'll see 'Connected' in the menu"
    echo ""
    echo "${green}After logging in, run this script again:${normal}"
    echo "curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/tailscale-upgrade.sh | bash"
    echo ""
    
    # Wait for user acknowledgment
    echo "Press Enter after you've logged into Tailscale..."
    read -r
    
    # Check again
    if ! check_tailscale_running; then
        echo "${red}X Tailscale still not running${normal}"
        echo "Please make sure you've:"
        echo "1. Opened the Tailscale app"
        echo "2. Logged in via the menu bar icon"
        echo "3. See 'Connected' status"
        exit 1
    fi
fi

# Get Tailscale status
echo "${green}✓ Tailscale is running!${normal}"

# Get hostname
TS_HOSTNAME=$(tailscale status --json 2>/dev/null | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('Self', {}).get('HostName', ''))" 2>/dev/null || echo "")

if [ -z "$TS_HOSTNAME" ]; then
    # Try to get hostname another way
    TS_HOSTNAME=$(hostname -s)
    
    echo "${yellow}Setting Tailscale hostname to: $TS_HOSTNAME${normal}"
    
    # Try to set hostname
    if command_exists sudo; then
        sudo tailscale set --hostname "$TS_HOSTNAME" 2>/dev/null || {
            echo "${yellow}Note: Could not set custom hostname${normal}"
        }
    fi
fi

echo "   Hostname: $TS_HOSTNAME"
echo "   Status: Connected"

# Get Tailscale IP
TS_IP=$(tailscale ip -4 2>/dev/null || echo "")
if [ -n "$TS_IP" ]; then
    echo "   Tailscale IP: $TS_IP"
fi

echo ""
echo "${blue}Setting up Pocket IDE for Tailscale...${normal}"

# Create enhanced directory structure
POCKET_IDE_DIR="$HOME/.pocket-ide"
mkdir -p "$POCKET_IDE_DIR/bin"
mkdir -p "$POCKET_IDE_DIR/config"

# Download enhanced scripts
echo "Downloading enhanced scripts..."

# Download the diagnostic script
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/pocket-diagnose.sh -o "$POCKET_IDE_DIR/bin/pocket-diagnose.sh" 2>/dev/null || echo "[!] Could not download diagnostic script"
chmod +x "$POCKET_IDE_DIR/bin/pocket-diagnose.sh" 2>/dev/null || true

# Download the updated pocket-quick.sh
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/pocket-quick.sh -o "$POCKET_IDE_DIR/bin/pocket-quick.sh" 2>/dev/null || echo "[!] Could not download pocket-quick script"
chmod +x "$POCKET_IDE_DIR/bin/pocket-quick.sh" 2>/dev/null || true

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
echo ""
echo "Setting up shortcuts..."

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
alias p='~/.pocket-ide/bin/pocket-quick.sh p'
alias w='~/.pocket-ide/bin/pocket-quick.sh w'
alias fix='~/.pocket-ide/bin/pocket-quick.sh fix'
alias keys='~/.pocket-ide/bin/pocket-quick.sh keys'
alias z='~/.pocket-ide/bin/pocket-quick.sh z'
alias x='~/.pocket-ide/bin/pocket-quick.sh x'

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
TAILSCALE_IP="$TS_IP"
TAILSCALE_ENABLED=true
AUTO_ATTACH_ON_SSH=true
EOF

# Show success message
echo ""
echo "${green}${bold}Tailscale upgrade complete!${normal}"
echo ""
echo "${bold}Mobile Setup Instructions:${normal}"
echo "-------------------------"
echo ""
echo "1. Install Tailscale on your phone:"
echo "   - iOS: App Store"
echo "   - Android: Play Store"
echo ""
echo "2. Login with the SAME account you used here"
echo ""
echo "3. In Termius, add new host:"
echo "   - Hostname: ${bold}$TS_HOSTNAME${normal}"
echo "   - Username: ${bold}$USER${normal}"
echo "   - Port: 22"
echo ""
echo "${bold}Ultra-short commands now available:${normal}"
echo "   ${bold}s${normal} = status     ${bold}r${normal} = run command"
echo "   ${bold}d${normal} = dashboard  ${bold}h${normal} = help"
echo "   ${bold}fix${normal} = diagnose & repair session"
echo ""
echo "${yellow}Quick Test:${normal}"
echo "Reload your shell and try: ${bold}d${normal}"
echo ""
echo "source ~/.zshrc"
