#!/bin/bash
# Pocket IDE Fix Script - Repairs installation and fixes RGB issues

echo "🔧 Fixing Pocket IDE installation..."

# Create necessary directories
mkdir -p ~/.pocket-ide/bin

# Create the unified pocket command
cat > ~/.pocket-ide/bin/pocket-unified << 'EOF'
#!/bin/bash
# Unified Pocket IDE Command
# This combines session management and quick commands

SESSION="vibecode"
PROJECT_DIR="${POCKET_IDE_PROJECT_DIR:-$(pwd)}"

# Fix terminal issues
fix_terminal() {
    # Clear any RGB escape sequences
    printf '\033[0m' 2>/dev/null || true
    # Reset terminal
    if command -v reset >/dev/null 2>&1; then
        reset >/dev/null 2>&1
    else
        clear
    fi
}

# Session management
case "${1:-help}" in
    start)
        # Fix terminal before starting
        fix_terminal
        
        if tmux has-session -t $SESSION 2>/dev/null; then
            echo "📱 Attaching to existing Pocket IDE session..."
            exec tmux attach-session -t $SESSION
        else
            echo "🚀 Creating new Pocket IDE session..."
            echo "📁 Working directory: $PROJECT_DIR"
            
            # Create session in current directory
            tmux new-session -d -s $SESSION -n 'main' -c "$PROJECT_DIR"
            tmux split-window -h -t $SESSION:0 -c "$PROJECT_DIR"
            tmux resize-pane -t $SESSION:0.0 -x 60%
            
            # Start Claude if available
            if command -v claude &> /dev/null; then
                tmux send-keys -t $SESSION:0.0 'claude' Enter
            else
                tmux send-keys -t $SESSION:0.0 'echo "Claude Code not found. Start it manually with: cc"' Enter
            fi
            
            tmux send-keys -t $SESSION:0.1 "clear" Enter
            tmux new-window -t $SESSION:1 -n 'monitor' -c "$PROJECT_DIR"
            tmux select-window -t $SESSION:0
            
            echo "✅ Session created!"
            sleep 0.5
            exec tmux attach-session -t $SESSION
        fi
        ;;
        
    kill|stop)
        if tmux has-session -t $SESSION 2>/dev/null; then
            tmux kill-session -t $SESSION
            echo "💀 Pocket IDE session terminated"
        else
            echo "No session to kill"
        fi
        ;;
        
    # Quick commands
    status|s)
        if ! tmux has-session -t $SESSION 2>/dev/null; then
            echo "❌ No session found. Run: pocket start"
            exit 1
        fi
        echo "=== Claude Status (last 20 lines) ==="
        tmux capture-pane -t $SESSION:0.0 -p | tail -20
        ;;
        
    run|r)
        if ! tmux has-session -t $SESSION 2>/dev/null; then
            echo "❌ No session found. Run: pocket start"
            exit 1
        fi
        shift
        if [ -z "$*" ]; then
            echo "Usage: pocket run <command>"
            exit 1
        fi
        echo "Sending to Claude: $*"
        tmux send-keys -t $SESSION:0.0 "$*" Enter
        ;;
        
    clear|c)
        if ! tmux has-session -t $SESSION 2>/dev/null; then
            echo "❌ No session found. Run: pocket start"
            exit 1
        fi
        tmux send-keys -t $SESSION:0.0 "clear" Enter
        echo "✓ Claude pane cleared"
        ;;
        
    fix)
        fix_terminal
        echo "✅ Terminal reset"
        ;;
        
    help|h|*)
        echo "Pocket IDE - Unified Command"
        echo ""
        echo "Session Management:"
        echo "  pocket start      - Start or attach to session"
        echo "  pocket kill       - Terminate session"
        echo "  pocket fix        - Fix terminal issues"
        echo ""
        echo "Quick Commands:"
        echo "  pocket status     - Show Claude's last output"
        echo "  pocket run <cmd>  - Send command to Claude"
        echo "  pocket clear      - Clear Claude's screen"
        echo ""
        echo "Short aliases:"
        echo "  s = status, r = run, c = clear"
        ;;
esac
EOF

# Make it executable
chmod +x ~/.pocket-ide/bin/pocket-unified

# Create auto-attach symlink
ln -sf ~/.pocket-ide/bin/pocket-unified ~/.pocket-ide/bin/auto-attach.sh

# Create pocket-ide start script symlink
ln -sf ~/.pocket-ide/bin/pocket-unified ~/.pocket-ide/start-pocket-ide.sh

# Create pocket-commands symlink
ln -sf ~/.pocket-ide/bin/pocket-unified ~/.pocket-ide/pocket-commands.sh

# Update pocket-quick.sh to use the fixed version
ln -sf ~/.pocket-ide/bin/pocket-unified ~/.pocket-ide/bin/pocket-quick.sh

# Ensure ~/.local/bin exists and is in PATH
mkdir -p ~/.local/bin

# Create main pocket command
ln -sf ~/.pocket-ide/bin/pocket-unified ~/.local/bin/pocket
ln -sf ~/.pocket-ide/bin/pocket-unified ~/.local/bin/pocket-ide

echo "✅ Installation fixed!"
echo ""
echo "Test it with:"
echo "  pocket kill    # Clean up any broken sessions"
echo "  pocket start   # Start fresh"
echo ""
echo "If you still see RGB codes, run:"
echo "  pocket fix"
echo ""
echo "You may need to reload your shell:"
echo "  source ~/.zshrc"
