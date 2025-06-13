#!/bin/bash
# Pocket IDE Starter Script - Enhanced
# This script creates and manages your persistent development environment

SESSION="vibecode"
# Use current directory if POCKET_IDE_PROJECT_DIR not set
PROJECT_DIR="${POCKET_IDE_PROJECT_DIR:-$(pwd)}"

# Colors for output
if [[ -t 1 ]] && [[ -n "$TERM" ]] && which tput &>/dev/null; then
    bold="$(tput bold)"
    normal="$(tput sgr0)"
    red="$(tput setaf 1)"
    green="$(tput setaf 2)"
    yellow="$(tput setaf 3)"
    blue="$(tput setaf 4)"
else
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
        echo -e "${red}❌ tmux is not installed${normal}"
        echo "   Run: brew install tmux"
        missing=1
    else
        echo -e "${green}✓ tmux found${normal}"
    fi
    
    if ! command -v claude &> /dev/null; then
        echo -e "${yellow}⚠️  Claude Code not found in PATH${normal}"
        echo "   Make sure Claude Code is installed and in your PATH"
        echo "   You can still continue, but you'll need to start Claude manually"
    else
        echo -e "${green}✓ Claude Code found${normal}"
    fi
    
    # Show project directory
    echo -e "${blue}📁 Project directory: $PROJECT_DIR${normal}"
    
    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${yellow}📁 Creating project directory: $PROJECT_DIR${normal}"
        mkdir -p "$PROJECT_DIR"
    fi
    
    if [ $missing -eq 1 ]; then
        echo -e "\n${red}Please install missing prerequisites before continuing.${normal}"
        exit 1
    fi
}

# Create or attach to session
start_session() {
    # Check if session exists
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo -e "\n${green}📱 Pocket IDE session already running!${normal}"
        echo "Attaching to existing session..."
        tmux attach-session -t $SESSION
    else
        echo -e "\n${green}🚀 Creating new Pocket IDE session...${normal}"
        echo -e "   Working directory: ${blue}$PROJECT_DIR${normal}"
        
        # Create new session with custom layout IN THE CURRENT/SPECIFIED DIRECTORY
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
        tmux send-keys -t $SESSION:0.1 'clear && echo "🎯 Terminal ready in: $(pwd)"' Enter
        
        # Create a second window for monitoring/logs
        tmux new-window -t $SESSION:1 -n 'monitor' -c "$PROJECT_DIR"
        
        # Switch back to main window
        tmux select-window -t $SESSION:0
        
        # Attach to session
        echo -e "${green}✅ Pocket IDE session created!${normal}"
        echo -e "\nSession layout:"
        echo "  Window 0 'main':"
        echo "    - Left pane:  Claude Code"
        echo "    - Right pane: Project terminal"
        echo "  Window 1 'monitor':"
        echo "    - For logs, monitoring, etc."
        echo -e "\nUseful tmux commands:"
        echo "  - Switch panes:   Ctrl+b → arrow keys"
        echo "  - Switch windows: Ctrl+b → 0/1"
        echo "  - Detach:         Ctrl+b → d"
        echo -e "\nAttaching to session..."
        sleep 2
        tmux attach-session -t $SESSION
    fi
}

# Show status
show_status() {
    echo -e "\n${yellow}📊 Pocket IDE Status${normal}"
    
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo -e "${green}✓ Session is running${normal}"
        echo -e "\nWindows:"
        tmux list-windows -t $SESSION
        echo -e "\nTo attach: ${green}tmux attach -t $SESSION${normal}"
    else
        echo -e "${red}✗ No session found${normal}"
        echo -e "\nTo start: ${green}$0 start${normal}"
    fi
}

# Kill session
kill_session() {
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo -e "${yellow}⚠️  Killing Pocket IDE session...${normal}"
        tmux kill-session -t $SESSION
        echo -e "${green}✓ Session terminated${normal}"
    else
        echo -e "${yellow}No session to kill${normal}"
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