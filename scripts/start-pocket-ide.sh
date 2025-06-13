#!/bin/bash
# Pocket IDE Starter Script - Enhanced
# This script creates and manages your persistent development environment

SESSION="vibecode"
# Use current directory if POCKET_IDE_PROJECT_DIR not set
PROJECT_DIR="${POCKET_IDE_PROJECT_DIR:-$(pwd)}"

# Fix terminal environment
export TERM="${TERM:-xterm-256color}"

# More robust color detection
if [[ -t 1 ]] && [[ -n "$TERM" ]] && command -v tput >/dev/null 2>&1; then
    # Check if terminal actually supports colors
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

# Check prerequisites
check_prerequisites() {
    local missing=0
    
    echo "🔍 Checking prerequisites..."
    
    if ! command -v tmux &> /dev/null; then
        echo "${red}❌ tmux is not installed${normal}"
        echo "   Run: brew install tmux"
        missing=1
    else
        echo "${green}✓ tmux found${normal}"
    fi
    
    if ! command -v claude &> /dev/null; then
        echo "${yellow}⚠️  Claude Code not found in PATH${normal}"
        echo "   Make sure Claude Code is installed and in your PATH"
        echo "   You can still continue, but you'll need to start Claude manually"
    else
        echo "${green}✓ Claude Code found${normal}"
    fi
    
    # Show project directory
    echo "${blue}📁 Project directory: $PROJECT_DIR${normal}"
    
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "${yellow}📁 Creating project directory: $PROJECT_DIR${normal}"
        mkdir -p "$PROJECT_DIR"
    fi
    
    if [ $missing -eq 1 ]; then
        echo ""
        echo "${red}Please install missing prerequisites before continuing.${normal}"
        exit 1
    fi
}

# Create or attach to session
start_session() {
    # Clean any stray escape sequences
    printf '\033[0m' 2>/dev/null || true
    
    # Check if session exists
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo ""
        echo "${green}📱 Pocket IDE session already running!${normal}"
        echo "Attaching to existing session..."
        exec tmux attach-session -t $SESSION
    else
        echo ""
        echo "${green}🚀 Creating new Pocket IDE session...${normal}"
        echo "   Working directory: ${blue}$PROJECT_DIR${normal}"
        
        # Kill any zombie sessions first
        tmux kill-session -t $SESSION 2>/dev/null || true
        
        # Create new session with custom layout
        tmux new-session -d -s $SESSION -n 'main' -c "$PROJECT_DIR"
        
        # Split window horizontally (left: Claude, right: terminal)
        tmux split-window -h -t $SESSION:0 -c "$PROJECT_DIR"
        
        # Make left pane slightly larger (60/40 split)
        tmux resize-pane -t $SESSION:0.0 -x 60%
        
        # Set up left pane for Claude
        if command -v claude &> /dev/null; then
            tmux send-keys -t $SESSION:0.0 'claude' Enter
        else
            tmux send-keys -t $SESSION:0.0 'echo "Claude Code not found. Please start it manually."' Enter
        fi
        
        # Set up right pane (already in project directory)
        tmux send-keys -t $SESSION:0.1 "clear && echo '🎯 Terminal ready in: $PROJECT_DIR'" Enter
        
        # Create a second window for monitoring/logs
        tmux new-window -t $SESSION:1 -n 'monitor' -c "$PROJECT_DIR"
        
        # Switch back to main window
        tmux select-window -t $SESSION:0
        
        # Small delay to ensure everything is set up
        sleep 0.5
        
        # Attach to session
        echo "${green}✅ Pocket IDE session created!${normal}"
        echo ""
        echo "Session layout:"
        echo "  Window 0 'main':"
        echo "    - Left pane:  Claude Code"
        echo "    - Right pane: Project terminal"
        echo "  Window 1 'monitor':"
        echo "    - For logs, monitoring, etc."
        echo ""
        echo "Useful tmux commands:"
        echo "  - Switch panes:   Ctrl+b → arrow keys"
        echo "  - Switch windows: Ctrl+b → 0/1"
        echo "  - Detach:         Ctrl+b → d"
        echo ""
        echo "Attaching to session..."
        sleep 1
        exec tmux attach-session -t $SESSION
    fi
}

# Show status
show_status() {
    echo ""
    echo "${yellow}📊 Pocket IDE Status${normal}"
    
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo "${green}✓ Session is running${normal}"
        echo ""
        echo "Windows:"
        tmux list-windows -t $SESSION
        echo ""
        echo "To attach: ${green}tmux attach -t $SESSION${normal}"
    else
        echo "${red}✗ No session found${normal}"
        echo ""
        echo "To start: ${green}$0 start${normal}"
    fi
}

# Kill session
kill_session() {
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo "${yellow}⚠️  Killing Pocket IDE session...${normal}"
        tmux kill-session -t $SESSION
        echo "${green}✓ Session terminated${normal}"
    else
        echo "${yellow}No session to kill${normal}"
    fi
}

# Main script logic
case "${1:-start}" in
    start)
        check_prerequisites
        start_session
        ;;
    status)
        show_status
        ;;
    kill|stop)
        kill_session
        ;;
    *)
        echo "Pocket IDE Manager"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  start   - Start or attach to Pocket IDE session (default)"
        echo "  status  - Show session status"
        echo "  kill    - Terminate the session"
        echo ""
        echo "Environment variables:"
        echo "  POCKET_IDE_PROJECT_DIR - Set project directory (default: current directory)"
        echo ""
        echo "Current directory: $(pwd)"
        ;;
esac
