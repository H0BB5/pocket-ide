#!/bin/bash
# Pocket IDE Quick Commands - Ultra-short for mobile

SESSION="vibecode"

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
        # Try to repair - use current directory or home
        if [ "$pane_count" -eq 1 ]; then
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
            echo "[OK] Sent: $*"
        else
            echo "[!] Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    c)  # Clear
        if pane_exists "$SESSION:0.0"; then
            tmux send-keys -t $SESSION:0.0 "clear" Enter
        else
            echo "[!] Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    k)  # Kill current process
        if pane_exists "$SESSION:0.0"; then
            # Check if Claude is actually running something
            last_line=$(tmux capture-pane -t $SESSION:0.0 -p | tail -1)
            if [[ "$last_line" == *"claude>"* ]]; then
                echo "[i] Claude is idle (nothing to interrupt)"
            else
                tmux send-keys -t $SESSION:0.0 C-c
                echo "[!] Interrupted"
            fi
        else
            echo "[!] Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    rs) # Restart Claude
        if pane_exists "$SESSION:0.0"; then
            tmux send-keys -t $SESSION:0.0 C-c
            sleep 0.5
            tmux send-keys -t $SESSION:0.0 "claude" Enter
            echo "[OK] Restarted Claude"
        else
            echo "[!] Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    
    # Navigation - Fixed for tmux nesting
    1)  # Claude pane
        if pane_exists "$SESSION:0.0"; then
            if [ -n "$TMUX" ]; then
                # Already in tmux, just switch pane
                tmux select-pane -t $SESSION:0.0
            else
                # Not in tmux, attach to session
                tmux select-pane -t $SESSION:0.0
                tmux attach-session -t $SESSION
            fi
        else
            echo "[!] Claude pane not found. Run 'fix' to repair."
        fi
        ;;
    2)  # Terminal pane
        if pane_exists "$SESSION:0.1"; then
            if [ -n "$TMUX" ]; then
                # Already in tmux, just switch pane
                tmux select-pane -t $SESSION:0.1
            else
                # Not in tmux, attach to session
                tmux select-pane -t $SESSION:0.1
                tmux attach-session -t $SESSION
            fi
        else
            echo "[!] Terminal pane not found. Run 'fix' to repair."
        fi
        ;;
    3)  # Monitor window
        if [ -n "$TMUX" ]; then
            # Already in tmux, just switch window
            tmux select-window -t $SESSION:1 2>/dev/null || echo "[!] Monitor window not found"
        else
            # Not in tmux, attach to session
            tmux select-window -t $SESSION:1 2>/dev/null || echo "[!] Monitor window not found"
            tmux attach-session -t $SESSION
        fi
        ;;
    
    # Additional navigation helpers
    p)  # Previous pane
        if [ -n "$TMUX" ]; then
            tmux select-pane -t :.+
        else
            echo "[!] Not in tmux session. Use 'pocket' to attach first."
        fi
        ;;
    w)  # List windows
        tmux list-windows -t $SESSION 2>/dev/null || echo "[!] No session found"
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
                echo "[OK] Changed directory to: $*"
            else
                tmux send-keys -t $SESSION:0.1 "cd" Enter
                echo "[OK] Changed to home directory"
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
            echo "[!] No session found. Run 'pocket-ide start' to create."
            exit 1
        fi
        
        echo "Claude Status:"
        if pane_exists "$SESSION:0.0"; then
            if tmux capture-pane -t $SESSION:0.0 -p 2>/dev/null | tail -1 | grep -q "claude>"; then
                echo "   [OK] Ready for input"
            else
                echo "   [...] Working"
                echo ""
                echo "Last output:"
                tmux capture-pane -t $SESSION:0.0 -p | tail -3 | sed 's/^/   /'
            fi
        else
            echo "   [!] Claude pane missing"
        fi
        
        echo ""
        echo "Current Directory:"
        if pane_exists "$SESSION:0.1"; then
            # Try to get the actual pwd from the pane
            local term_content=$(tmux capture-pane -t $SESSION:0.1 -p | tail -20)
            local pwd_line=$(echo "$term_content" | grep -E "^[~/].*\$" | tail -1 | sed 's/\$.*//'
            if [ -n "$pwd_line" ]; then
                echo "   $pwd_line"
            else
                echo "   [unknown - use 'pwd' to check]"
            fi
        else
            echo "   [!] Terminal pane missing"
        fi
        
        echo ""
        echo "Quick Commands:"
        echo "   s=status  r=run  c=clear  k=kill"
        echo "   1=claude  2=term  3=monitor  p=next-pane"
        echo "   fix=diagnose  rs=restart"
        if [ -n "$TMUX" ]; then
            echo ""
            echo "   [You're in tmux - pane switching ready]"
        fi
        ;;
    
    # Diagnostic/Fix command
    fix|diag|diagnose)
        if [ -x "$HOME/.pocket-ide/bin/pocket-diagnose.sh" ]; then
            $HOME/.pocket-ide/bin/pocket-diagnose.sh
        else
            echo "[!] Diagnostic script not found"
            echo "Quick fix attempt..."
            tmux kill-session -t $SESSION 2>/dev/null
            $HOME/.pocket-ide/start-pocket-ide.sh
            echo "[OK] Session recreated. Try your commands again!"
        fi
        ;;
    
    # Help
    h)  # Help
        echo "POCKET IDE QUICK COMMANDS"
        echo ""
        echo "STATUS            ACTION            NAV"
        echo "s  - status       r <cmd> - run     1 - claude"
        echo "l  - last 10      c - clear         2 - terminal"
        echo "ll - last 50      k - kill process  3 - monitor"
        echo "d  - dashboard    rs - restart      p - next pane"
        echo "fix - diagnose                     w - list windows"
        echo "pwd - show dir    cd - change dir"
        echo ""
        echo "Example: r 'create a hello world'"
        echo ""
        if [ -n "$TMUX" ]; then
            echo "TIP: You're in tmux. Use numbers to switch panes directly."
        else
            echo "TIP: Run 'pocket' first to attach to the session."
        fi
        echo ""
        echo "Session broken? Run 'fix' to diagnose and repair."
        ;;
    
    # Default to dashboard
    *)
        $0 d
        ;;
esac