#!/bin/bash
# Pocket IDE Quick Commands - Ultra-short for mobile

SESSION="vibecode"

# Fix terminal environment
export TERM="${TERM:-xterm-256color}"

# More robust color detection
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    ncolors=$(tput colors 2>/dev/null || echo 0)
    if [[ -n "$ncolors" ]] && [[ "$ncolors" -ge 8 ]]; then
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
        echo "${yellow}[!]${normal} No session found. Creating new session..."
        # Use the fixed start script
        if [ -x "$HOME/.pocket-ide/start-pocket-ide.sh" ]; then
            export POCKET_IDE_NO_ATTACH=1  # Prevent auto-attach
            $HOME/.pocket-ide/start-pocket-ide.sh start > /dev/null 2>&1
            sleep 1  # Give it time to create
        else
            # Fallback: create basic session
            tmux new-session -d -s $SESSION -n 'main' -c "${PWD:-$HOME}"
            tmux split-window -h -t $SESSION:0 -c "${PWD:-$HOME}"
            tmux resize-pane -t $SESSION:0.0 -x 60%
            if command -v claude &> /dev/null; then
                tmux send-keys -t $SESSION:0.0 'claude' Enter
            fi
        fi
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

# Clean any stray escape sequences before output
clean_output() {
    printf '\033[0m' 2>/dev/null || true
}

# Command shortcuts
case "${1:-d}" in
    # Status commands
    s)  # Status
        clean_output
        if pane_exists "$SESSION:0.0"; then
            tmux capture-pane -t $SESSION:0.0 -p | tail -20
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    l)  # Last 10 lines
        clean_output
        if pane_exists "$SESSION:0.0"; then
            tmux capture-pane -t $SESSION:0.0 -p | tail -10
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    ll) # Last 50 lines
        clean_output
        if pane_exists "$SESSION:0.0"; then
            tmux capture-pane -t $SESSION:0.0 -p | tail -50
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
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
    
    # Pane management
    close|x)  # Close current pane
        if [ -n "$TMUX" ]; then
            # Get current pane info
            current_pane=$(tmux display-message -p '#P')
            pane_count=$(tmux list-panes -t $SESSION:0 | wc -l)
            
            if [ "$pane_count" -le 1 ]; then
                echo "${red}[!]${normal} Cannot close the last pane!"
                echo "    Use 'exit' to end the session"
            else
                echo "Closing current pane..."
                tmux kill-pane
                echo "${green}[OK]${normal} Pane closed"
                
                # Check if we still have proper structure
                new_pane_count=$(tmux list-panes -t $SESSION:0 2>/dev/null | wc -l || echo 0)
                if [ "$new_pane_count" -lt 2 ]; then
                    echo "${yellow}[i]${normal} Session structure altered. Run 'fix' to restore."
                fi
            fi
        else
            echo "${red}[!]${normal} Not in tmux. Use 'pocket' to attach first."
        fi
        ;;
    
    split)  # Split window
        if [ -n "$TMUX" ]; then
            case "${2:-h}" in
                h|horizontal)
                    tmux split-window -h -c "#{pane_current_path}"
                    echo "${green}[OK]${normal} Split horizontally"
                    ;;
                v|vertical)
                    tmux split-window -v -c "#{pane_current_path}"
                    echo "${green}[OK]${normal} Split vertically"
                    ;;
                *)
                    echo "Usage: split [h|v]"
                    ;;
            esac
        else
            echo "${red}[!]${normal} Not in tmux. Use 'pocket' to attach first."
        fi
        ;;
    
    # Navigation - Fixed for tmux nesting
    1|claude)  # Claude pane
        if pane_exists "$SESSION:0.0"; then
            if [ -n "$TMUX" ]; then
                # Already in tmux, just switch pane
                tmux select-pane -t $SESSION:0.0
                echo "${green}[Switched to Claude pane]${normal}"
            else
                # Not in tmux, need to attach
                echo "${yellow}[!]${normal} Not in tmux. Run 'pocket' first to attach."
            fi
        else
            echo "${red}[!]${normal} Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    2|term|terminal)  # Terminal pane
        if pane_exists "$SESSION:0.1"; then
            if [ -n "$TMUX" ]; then
                # Already in tmux, just switch pane
                tmux select-pane -t $SESSION:0.1
                echo "${green}[Switched to terminal pane]${normal}"
            else
                # Not in tmux, need to attach
                echo "${yellow}[!]${normal} Not in tmux. Run 'pocket' first to attach."
            fi
        else
            echo "${red}[!]${normal} Terminal pane not found. Run 'fix' to repair."
        fi
        ;;
    3)  # Monitor window
        if [ -n "$TMUX" ]; then
            # Already in tmux, just switch window
            tmux select-window -t $SESSION:1 2>/dev/null || echo "${yellow}[!]${normal} Monitor window not found"
        else
            # Not in tmux, attach to session
            echo "${yellow}[!]${normal} Not in tmux. Run 'pocket' first to attach."
        fi
        ;;
    
    # Mobile-friendly pane switching
    left|<)  # Go to left pane (Claude)
        if [ -n "$TMUX" ]; then
            tmux select-pane -L
            echo "${green}[Switched left]${normal}"
        else
            echo "${yellow}[!]${normal} Not in tmux. Run 'pocket' first."
        fi
        ;;
    right|>)  # Go to right pane (Terminal)
        if [ -n "$TMUX" ]; then
            tmux select-pane -R
            echo "${green}[Switched right]${normal}"
        else
            echo "${yellow}[!]${normal} Not in tmux. Run 'pocket' first."
        fi
        ;;
    zoom|z)  # Toggle zoom
        if [ -n "$TMUX" ]; then
            tmux resize-pane -Z
            # Check if zoomed
            if tmux list-panes -F '#F' | grep -q Z; then
                echo "${green}[OK]${normal} Pane zoomed (fullscreen)"
            else
                echo "${green}[OK]${normal} Pane unzoomed"
            fi
        else
            echo "${yellow}[!]${normal} Not in tmux. Run 'pocket' first."
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
            echo "${red}[!]${normal} Terminal pane not found"
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
            echo "${red}[!]${normal} Terminal pane not found"
        fi
        ;;
    
    # Dashboard view
    d)  # Dashboard
        clean_output
        ensure_session_structure
        
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
                tmux capture-pane -t $SESSION:0.0 -p 2>/dev/null | tail -3 | sed 's/^/   /' || echo "   [Unable to capture]"
            fi
        else
            echo "   ${red}[!]${normal} Claude pane missing"
        fi
        
        echo ""
        echo "Current Directory:"
        if pane_exists "$SESSION:0.1"; then
            # Try to get the actual pwd from the pane
            local term_content=$(tmux capture-pane -t $SESSION:0.1 -p 2>/dev/null | tail -20)
            local pwd_line=$(echo "$term_content" | grep -E "^[~/].*\$" | tail -1 | sed 's/\$.*//' | sed 's/^[ \t]*//')
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
        else
            echo ""
            echo "   ${yellow}[Not in tmux - run 'pocket' to attach]${normal}"
        fi
        ;;
    
    # Diagnostic/Fix command
    fix|diag|diagnose)
        clean_output
        if [ -x "$HOME/.pocket-ide/bin/pocket-diagnose.sh" ]; then
            $HOME/.pocket-ide/bin/pocket-diagnose.sh
        else
            echo "${yellow}[!]${normal} Diagnostic script not found"
            echo "Quick fix attempt..."
            tmux kill-session -t $SESSION 2>/dev/null
            # Create fresh session
            tmux new-session -d -s $SESSION -n 'main' -c "${PWD:-$HOME}"
            tmux split-window -h -t $SESSION:0 -c "${PWD:-$HOME}"
            tmux resize-pane -t $SESSION:0.0 -x 60%
            if command -v claude &> /dev/null; then
                tmux send-keys -t $SESSION:0.0 'claude' Enter
            fi
            echo "${green}[OK]${normal} Session recreated. Try your commands again!"
        fi
        ;;
    
    # Show tmux key reference
    keys)
        clean_output
        echo "TMUX KEY REFERENCE"
        echo "=================="
        echo ""
        echo "${yellow}When Claude is active, numbers won't work!${normal}"
        echo "Use these tmux commands instead:"
        echo ""
        echo "Prefix: Ctrl+b (then release, then press key)"
        echo ""
        echo "PANE NAVIGATION:"
        echo "  Ctrl+b → ←   Switch panes left/right"
        echo "  Ctrl+b ↑ ↓   Switch panes up/down"
        echo "  Ctrl+b q     Show pane numbers (then press number)"
        echo "  Ctrl+b z     Zoom/unzoom current pane"
        echo "  Ctrl+b o     Cycle through panes"
        echo ""
        echo "WINDOW NAVIGATION:"
        echo "  Ctrl+b 0     Go to window 0 (main)"
        echo "  Ctrl+b 1     Go to window 1 (monitor)"
        echo "  Ctrl+b n     Next window"
        echo "  Ctrl+b p     Previous window"
        echo ""
        echo "SESSION:"
        echo "  Ctrl+b d     Detach from session"
        echo "  Ctrl+b $     Rename session"
        echo ""
        echo "${green}TIP:${normal} Switch to terminal pane first,"
        echo "     then number shortcuts work!"
        ;;
    
    # Help
    h)  # Help
        clean_output
        echo "POCKET IDE QUICK COMMANDS"
        echo "========================"
        echo ""
        echo "${green}STATUS${normal}            ${yellow}ACTION${normal}            ${red}NAV${normal}"
        echo "s  - status       r <cmd> - run     left - to claude"
        echo "l  - last 10      c - clear         right - to term"
        echo "ll - last 50      k - kill process  zoom - toggle"
        echo "d  - dashboard    rs - restart      1/claude - claude"
        echo "fix - diagnose    cd - change dir   2/term - terminal"
        echo "pwd - show dir    keys - tmux help  p/next - cycle"
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
            echo "Type 'keys' for tmux reference."
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
        # Ensure session exists before showing dashboard
        ensure_session_structure
        $0 d
        ;;
esac
