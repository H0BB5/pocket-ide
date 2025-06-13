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
            tmux split-window -h -t $SESSION:0 -c "$HOME/projects" 2>/dev/null || true
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
    
    # Navigation - Fixed for tmux nesting
    1)  # Claude pane
        if pane_exists "$SESSION:0.0"; then
            if [ -n "$TMUX" ]; then
                # Already in tmux, just switch pane
                tmux select-pane -t $SESSION:0.0
                echo "${green}[Switched to Claude pane]${normal}"
                echo "${yellow}TIP:${normal} Use Ctrl+b then arrow keys to switch panes while Claude is active"
            else
                # Not in tmux, attach to session
                tmux select-pane -t $SESSION:0.0
                tmux attach-session -t $SESSION
            fi
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    2)  # Terminal pane
        if pane_exists "$SESSION:0.1"; then
            if [ -n "$TMUX" ]; then
                # Already in tmux, just switch pane
                tmux select-pane -t $SESSION:0.1
                echo "${green}[Switched to terminal pane]${normal}"
            else
                # Not in tmux, attach to session
                tmux select-pane -t $SESSION:0.1
                tmux attach-session -t $SESSION
            fi
        else
            echo "${red}[!]${normal} Terminal pane not found. Run 'fix' to repair."
        fi
        ;;
    3)  # Monitor window
        if [ -n "$TMUX" ]; then
            # Already in tmux, just switch window
            tmux select-window -t $SESSION:1 2>/dev/null || echo "${red}[!]${normal} Monitor window not found"
        else
            # Not in tmux, attach to session
            tmux select-window -t $SESSION:1 2>/dev/null || echo "${red}[!]${normal} Monitor window not found"
            tmux attach-session -t $SESSION
        fi
        ;;
    
    # Additional navigation helpers
    p)  # Previous pane
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
            tmux capture-pane -t $SESSION:0.1 -p | grep -E "^[~/].*\$" | tail -1 | sed 's/\$.*//' | sed 's/^/   /' || echo "   [unknown]"
        else
            echo "   ${red}[!]${normal} Terminal pane missing"
        fi
        
        echo ""
        echo "Quick Commands:"
        echo "   s=status  r=run  c=clear  k=kill"
        echo "   1=claude  2=term  3=monitor  p=next-pane"
        echo "   fix=diagnose  rs=restart"
        
        if [ -n "$TMUX" ]; then
            echo ""
            echo "   ${green}[You're in tmux]${normal}"
            echo ""
            echo "   ${yellow}Pane Navigation:${normal}"
            echo "   • Numbers (1,2,3) work from terminal pane"
            echo "   • From Claude pane use: Ctrl+b → arrow keys"
            echo "   • Or: Ctrl+b q (then press pane number)"
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
        echo "s  - status       r <cmd> - run     1 - claude"
        echo "l  - last 10      c - clear         2 - terminal"
        echo "ll - last 50      k - kill process  3 - monitor"
        echo "d  - dashboard    rs - restart      p - next pane"
        echo "fix - diagnose                     w - list windows"
        echo ""
        echo "Example: ${green}r 'create a hello world'${normal}"
        echo ""
        
        if [ -n "$TMUX" ]; then
            echo "${yellow}TMUX Navigation Tips:${normal}"
            echo "• When Claude is active, use tmux commands:"
            echo "  - ${green}Ctrl+b ←/→${normal} - Switch panes"
            echo "  - ${green}Ctrl+b q${normal} - Show pane numbers, then press number"
            echo "  - ${green}Ctrl+b z${normal} - Zoom current pane (toggle)"
            echo "  - ${green}Ctrl+b d${normal} - Detach from session"
        else
            echo "TIP: Run 'pocket' first to attach to the session."
        fi
        echo ""
        echo "Session broken? Run '${red}fix${normal}' to diagnose and repair."
        ;;
    
    # Tmux key reference
    keys|tmux)
        echo "TMUX KEY BINDINGS"
        echo "================="
        echo ""
        echo "${yellow}Essential Keys (Ctrl+b then...):${normal}"
        echo "  ${green}←/→/↑/↓${normal} - Switch panes by direction"
        echo "  ${green}q${normal}       - Show pane numbers (then press number)"
        echo "  ${green}z${normal}       - Zoom/unzoom current pane"
        echo "  ${green}d${normal}       - Detach from session"
        echo "  ${green}[${normal}       - Enter scroll mode (q to exit)"
        echo "  ${green}c${normal}       - Create new window"
        echo "  ${green}n/p${normal}     - Next/previous window"
        echo ""
        echo "${yellow}Copy Mode (Ctrl+b [ then...):${normal}"
        echo "  ${green}Space${normal}   - Start selection"
        echo "  ${green}Enter${normal}   - Copy selection"
        echo "  ${green}q${normal}       - Exit copy mode"
        echo ""
        echo "Remember: All commands need ${yellow}Ctrl+b${normal} first!"
        ;;
    
    # Default to dashboard
    *)
        $0 d
        ;;
esac