#!/bin/bash
# Pocket IDE Quick Commands - Ultra-short for mobile

SESSION="vibecode"

# Colors for output (if supported)
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    green="$(tput setaf 2 2>/dev/null || echo '')"
    yellow="$(tput setaf 3 2>/dev/null || echo '')"
    red="$(tput setaf 1 2>/dev/null || echo '')"
    normal="$(tput sgr0 2>/dev/null || echo '')"
else
    green=""
    yellow=""
    red=""
    normal=""
fi

# Function to check if pane exists
pane_exists() {
    tmux list-panes -t "$1" >/dev/null 2>&1
}

# Function to ensure session structure
ensure_session_structure() {
    if ! tmux has-session -t $SESSION 2>/dev/null; then
        $HOME/.pocket-ide/start-pocket-ide.sh > /dev/null 2>&1
        return
    fi
    
    # Check if we have the expected panes
    local pane_count=$(tmux list-panes -t $SESSION:0 2>/dev/null | wc -l || echo 0)
    if [ "$pane_count" -lt 2 ]; then
        # Try to repair
        if [ "$pane_count" -eq 1 ]; then
            # Use current directory or fall back to home
            local work_dir="${PWD:-$HOME}"
            tmux split-window -h -t $SESSION:0 -c "$work_dir" 2>/dev/null || true
            tmux resize-pane -t $SESSION:0.0 -x 60% 2>/dev/null || true
        fi
    fi
}

# Ensure session exists with proper structure
ensure_session_structure

# Command shortcuts
case "${1:-d}" in
    # Status commands
    s)  # Status
        if pane_exists "$SESSION:0.0"; then
            tmux capture-pane -t $SESSION:0.0 -p | tail -20
        else
            echo "[!] Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    l)  # Last 10 lines
        if pane_exists "$SESSION:0.0"; then
            tmux capture-pane -t $SESSION:0.0 -p | tail -10
        else
            echo "[!] Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    ll) # Last 50 lines
        if pane_exists "$SESSION:0.0"; then
            tmux capture-pane -t $SESSION:0.0 -p | tail -50
        else
            echo "[!] Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    
    # Action commands
    r)  # Run
        shift
        if pane_exists "$SESSION:0.0"; then
            tmux send-keys -t $SESSION:0.0 "$*" Enter
            echo "${green}[OK]${normal} Sent: $*"
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    c)  # Clear
        if pane_exists "$SESSION:0.0"; then
            tmux send-keys -t $SESSION:0.0 "clear" Enter
            echo "${green}[OK]${normal} Cleared Claude screen"
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    k)  # Kill current process
        if pane_exists "$SESSION:0.0"; then
            # Check if Claude is actually running something
            last_line=$(tmux capture-pane -t $SESSION:0.0 -p | tail -1)
            if [[ "$last_line" == *"claude>"* ]]; then
                echo "${yellow}[i]${normal} Claude is idle (nothing to interrupt)"
            else
                tmux send-keys -t $SESSION:0.0 C-c
                echo "${yellow}[!]${normal} Sent interrupt signal"
            fi
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    rs) # Restart Claude
        if pane_exists "$SESSION:0.0"; then
            tmux send-keys -t $SESSION:0.0 C-c
            sleep 0.5
            tmux send-keys -t $SESSION:0.0 "claude" Enter
            echo "${green}[OK]${normal} Restarted Claude"
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    
    # Navigation - Direct pane switching without Ctrl+b
    1|claude)  # Claude pane
        if pane_exists "$SESSION:0.0"; then
            if [ -n "$TMUX" ]; then
                # Send the tmux command directly (no prefix needed)
                tmux select-pane -t $SESSION:0.0
                echo "${green}[Switched to Claude pane]${normal}"
            else
                # Not in tmux, need to attach
                echo "[!] Not in tmux. Run 'pocket' first to attach."
            fi
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    2|term|terminal)  # Terminal pane
        if pane_exists "$SESSION:0.1"; then
            if [ -n "$TMUX" ]; then
                # Send the tmux command directly (no prefix needed)
                tmux select-pane -t $SESSION:0.1
                echo "${green}[Switched to terminal pane]${normal}"
            else
                # Not in tmux, need to attach
                echo "[!] Not in tmux. Run 'pocket' first to attach."
            fi
        else
            echo "${red}[!]${normal} Terminal pane not found. Run 'fix' to repair."
        fi
        ;;
    
    # Mobile-friendly pane switching
    left|<)  # Go to left pane (Claude)
        if [ -n "$TMUX" ]; then
            tmux select-pane -L
            echo "${green}[Switched left]${normal}"
        else
            echo "[!] Not in tmux. Run 'pocket' first."
        fi
        ;;
    right|>)  # Go to right pane (Terminal)
        if [ -n "$TMUX" ]; then
            tmux select-pane -R
            echo "${green}[Switched right]${normal}"
        else
            echo "[!] Not in tmux. Run 'pocket' first."
        fi
        ;;
    zoom|z)  # Toggle zoom
        if [ -n "$TMUX" ]; then
            tmux resize-pane -Z
            echo "${green}[Toggled zoom]${normal}"
        else
            echo "[!] Not in tmux. Run 'pocket' first."
        fi
        ;;
    
    # Additional navigation helpers
    p|next)  # Next pane
        if [ -n "$TMUX" ]; then
            tmux select-pane -t :.+
            echo "${green}[Switched pane]${normal}"
        else
            echo "${red}[!]${normal} Not in tmux session. Use 'pocket' to attach first."
        fi
        ;;
    w)  # List windows
        tmux list-windows -t $SESSION 2>/dev/null || echo "${red}[!]${normal} No session found"
        ;;
    
    # Show current directory
    pwd)
        if pane_exists "$SESSION:0.1"; then
            echo "Terminal pane directory:"
            tmux send-keys -t $SESSION:0.1 'pwd' Enter
            sleep 0.2
            tmux capture-pane -t $SESSION:0.1 -p | tail -2 | head -1
        else
            echo "[!] Terminal pane not found"
        fi
        ;;
    
    # Change directory in terminal pane
    cd)
        shift
        if pane_exists "$SESSION:0.1"; then
            if [ -n "$1" ]; then
                tmux send-keys -t $SESSION:0.1 "cd $*" Enter
                echo "${green}[OK]${normal} Changed directory to: $*"
            else
                tmux send-keys -t $SESSION:0.1 "cd" Enter
                echo "${green}[OK]${normal} Changed to home directory"
            fi
        else
            echo "[!] Terminal pane not found"
        fi
        ;;
    
    # Dashboard view
    d)  # Dashboard
        echo "POCKET IDE DASHBOARD"
        echo "==================="
        echo ""
        
        if ! tmux has-session -t $SESSION 2>/dev/null; then
            echo "${red}[!]${normal} No session found. Run 'pocket-ide start' to create."
            exit 1
        fi
        
        echo "Claude Status:"
        if pane_exists "$SESSION:0.0"; then
            last_line=$(tmux capture-pane -t $SESSION:0.0 -p 2>/dev/null | tail -1)
            if [[ "$last_line" == *"claude>"* ]]; then
                echo "   ${green}[OK]${normal} Ready for input"
            else
                echo "   ${yellow}[...]${normal} Working"
                echo ""
                echo "Last output:"
                tmux capture-pane -t $SESSION:0.0 -p | tail -3 | sed 's/^/   /'
            fi
        else
            echo "   ${red}[!]${normal} Claude pane missing"
        fi
        
        echo ""
        echo "Current Directory:"
        if pane_exists "$SESSION:0.1"; then
            # Try to get the actual pwd from the pane
            local term_content=$(tmux capture-pane -t $SESSION:0.1 -p | tail -20)
            local pwd_line=$(echo "$term_content" | grep -E "^[~/].*\$" | tail -1 | sed 's/\$.*//')
            if [ -n "$pwd_line" ]; then
                echo "   $pwd_line"
            else
                echo "   [unknown - use 'pwd' to check]"
            fi
        else
            echo "   ${red}[!]${normal} Terminal pane missing"
        fi
        
        echo ""
        echo "Quick Commands:"
        echo "   s=status  r=run  c=clear  k=kill"
        echo "   left=claude  right=term  zoom=toggle"
        echo "   fix=diagnose  rs=restart"
        
        if [ -n "$TMUX" ]; then
            echo ""
            echo "   ${green}[You're in tmux]${normal}"
            echo ""
            echo "   ${yellow}Mobile Navigation:${normal}"
            echo "   • 'left' or '<' - Switch to Claude"
            echo "   • 'right' or '>' - Switch to Terminal"
            echo "   • 'zoom' or 'z' - Zoom current pane"
            echo "   • '1' or 'claude' - Go to Claude"
            echo "   • '2' or 'term' - Go to Terminal"
        fi
        ;;
    
    # Diagnostic/Fix command
    fix|diag|diagnose)
        if [ -x "$HOME/.pocket-ide/bin/pocket-diagnose.sh" ]; then
            $HOME/.pocket-ide/bin/pocket-diagnose.sh
        else
            echo "${yellow}[!]${normal} Diagnostic script not found"
            echo "Quick fix attempt..."
            tmux kill-session -t $SESSION 2>/dev/null
            $HOME/.pocket-ide/start-pocket-ide.sh
            echo "${green}[OK]${normal} Session recreated. Try your commands again!"
        fi
        ;;
    
    # Help
    h)  # Help
        echo "POCKET IDE QUICK COMMANDS"
        echo "========================"
        echo ""
        echo "${green}STATUS${normal}            ${yellow}ACTION${normal}            ${red}NAV${normal}"
        echo "s  - status       r <cmd> - run     left - to claude"
        echo "l  - last 10      c - clear         right - to term"
        echo "ll - last 50      k - kill process  zoom - toggle"
        echo "d  - dashboard    rs - restart      1/claude - claude"
        echo "fix - diagnose    cd - change dir   2/term - terminal"
        echo "pwd - show dir                      p/next - cycle"
        echo ""
        echo "Example: ${green}r 'create a hello world'${normal}"
        echo ""
        
        if [ -n "$TMUX" ]; then
            echo "${yellow}MOBILE-FRIENDLY Navigation:${normal}"
            echo "• Use 'left'/'right' instead of Ctrl+b arrows"
            echo "• Use 'zoom' to focus on one pane"
            echo "• Use '1' or '2' to jump to specific pane"
            echo ""
            echo "${red}Ctrl+b not working?${normal} That's normal on mobile!"
            echo "All navigation commands work without it."
        else
            echo "TIP: Run 'pocket' first to attach to the session."
        fi
        echo ""
        echo "Session broken? Run '${red}fix${normal}' to diagnose and repair."
        ;;
    
    # Tmux prefix changer (for mobile)
    prefix)
        echo "Changing tmux prefix to Ctrl+a (easier on mobile)..."
        tmux set-option -g prefix C-a
        tmux unbind-key C-b
        tmux bind-key C-a send-prefix
        echo "${green}[OK]${normal} Tmux prefix changed to Ctrl+a"
        echo "Now use Ctrl+a instead of Ctrl+b"
        ;;
    
    # Default to dashboard
    *)
        $0 d
        ;;
esac