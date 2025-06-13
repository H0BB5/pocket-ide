#!/bin/bash
# Pocket Commands - Quick actions for mobile use
# This script provides easy-to-type commands for common actions

SESSION="vibecode"

# Check if session exists
if ! tmux has-session -t $SESSION 2>/dev/null; then
    echo "❌ No Pocket IDE session found"
    echo "Start one with: start-pocket-ide.sh"
    exit 1
fi

case "$1" in
    # Show Claude's last output
    status|s)
        echo "=== Claude Status (last 20 lines) ==="
        tmux capture-pane -t $SESSION:0.0 -p | tail -20
        ;;
    
    # Send command to Claude
    run|r)
        shift
        if [ -z "$*" ]; then
            echo "Usage: $0 run <command>"
            exit 1
        fi
        echo "Sending to Claude: $*"
        tmux send-keys -t $SESSION:0.0 "$*" Enter
        ;;
    
    # Clear Claude's pane
    clear|c)
        tmux send-keys -t $SESSION:0.0 "clear" Enter
        echo "✓ Claude pane cleared"
        ;;
    
    # Quick file operations
    ls)
        tmux send-keys -t $SESSION:0.1 "ls -la" Enter
        ;;
    
    pwd)
        tmux capture-pane -t $SESSION:0.1 -p | tail -1
        ;;
    
    # Switch to different pane/window
    switch|sw)
        case "$2" in
            claude|left|l)
                tmux select-pane -t $SESSION:0.0
                echo "✓ Switched to Claude pane"
                ;;
            terminal|right|r)
                tmux select-pane -t $SESSION:0.1
                echo "✓ Switched to terminal pane"
                ;;
            monitor|m)
                tmux select-window -t $SESSION:1
                echo "✓ Switched to monitor window"
                ;;
            *)
                echo "Usage: $0 switch [claude|terminal|monitor]"
                ;;
        esac
        ;;
    
    # Show all panes
    show|sh)
        echo "=== Main Window ==="
        echo "Left pane (Claude):"
        tmux capture-pane -t $SESSION:0.0 -p | tail -5
        echo ""
        echo "Right pane (Terminal):"
        tmux capture-pane -t $SESSION:0.1 -p | tail -5
        ;;
    
    # Help
    help|h|*)
        echo "Pocket Commands - Quick actions for mobile"
        echo ""
        echo "Usage: pocket [command] [args]"
        echo ""
        echo "Commands:"
        echo "  status, s      - Show Claude's last output"
        echo "  run, r <cmd>   - Send command to Claude"
        echo "  clear, c       - Clear Claude's screen"
        echo "  ls             - List files in project dir"
        echo "  pwd            - Show current directory"
        echo "  switch, sw     - Switch panes (claude/terminal/monitor)"
        echo "  show, sh       - Show all panes"
        echo "  help, h        - Show this help"
        echo ""
        echo "Examples:"
        echo "  pocket run 'create a Python hello world'"
        echo "  pocket switch claude"
        echo "  pocket status"
        ;;
esac