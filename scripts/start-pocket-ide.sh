#!/bin/bash
# Pocket IDE Starter Script
# This script creates and manages your persistent development environment

SESSION="vibecode"
PROJECT_DIR="${POCKET_IDE_PROJECT_DIR:-~/projects}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
check_prerequisites() {
    local missing=0
    
    echo "🔍 Checking prerequisites..."
    
    if ! command -v tmux &> /dev/null; then
        echo -e "${RED}❌ tmux is not installed${NC}"
        echo "   Run: brew install tmux"
        missing=1
    else
        echo -e "${GREEN}✓ tmux found${NC}"
    fi
    
    if ! command -v claude &> /dev/null; then
        echo -e "${YELLOW}⚠️  Claude Code not found in PATH${NC}"
        echo "   Make sure Claude Code is installed and in your PATH"
        echo "   You can still continue, but you'll need to start Claude manually"
    else
        echo -e "${GREEN}✓ Claude Code found${NC}"
    fi
    
    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${YELLOW}📁 Creating project directory: $PROJECT_DIR${NC}"
        mkdir -p "$PROJECT_DIR"
    fi
    
    if [ $missing -eq 1 ]; then
        echo -e "\n${RED}Please install missing prerequisites before continuing.${NC}"
        exit 1
    fi
}

# Create or attach to session
start_session() {
    # Check if session exists
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo -e "\n${GREEN}📱 Pocket IDE session already running!${NC}"
        echo "Attaching to existing session..."
        tmux attach-session -t $SESSION
    else
        echo -e "\n${GREEN}🚀 Creating new Pocket IDE session...${NC}"
        
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
        
        # Set up right pane
        tmux send-keys -t $SESSION:0.1 'clear && echo "🎯 Project Terminal Ready"' Enter
        
        # Create a second window for monitoring/logs
        tmux new-window -t $SESSION:1 -n 'monitor' -c "$PROJECT_DIR"
        
        # Switch back to main window
        tmux select-window -t $SESSION:0
        
        # Attach to session
        echo -e "${GREEN}✅ Pocket IDE session created!${NC}"
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
    echo -e "\n${YELLOW}📊 Pocket IDE Status${NC}"
    
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo -e "${GREEN}✓ Session is running${NC}"
        echo -e "\nWindows:"
        tmux list-windows -t $SESSION
        echo -e "\nTo attach: ${GREEN}tmux attach -t $SESSION${NC}"
    else
        echo -e "${RED}✗ No session found${NC}"
        echo -e "\nTo start: ${GREEN}$0 start${NC}"
    fi
}

# Kill session
kill_session() {
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Killing Pocket IDE session...${NC}"
        tmux kill-session -t $SESSION
        echo -e "${GREEN}✓ Session terminated${NC}"
    else
        echo -e "${YELLOW}No session to kill${NC}"
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
        echo "  POCKET_IDE_PROJECT_DIR - Set project directory (default: ~/projects)"
        ;;
esac