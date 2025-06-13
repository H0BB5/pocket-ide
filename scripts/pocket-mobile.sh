#!/bin/bash
# Pocket Mobile - Enhanced mobile experience
# This script provides a touch-friendly interface for mobile devices

SESSION="vibecode"

# Colors and formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Unicode icons that work well on mobile
ICON_CLAUDE="🤖"
ICON_TERMINAL="💻"
ICON_STATUS="📊"
ICON_RUN="▶️"
ICON_CLEAR="🧹"
ICON_KILL="🛑"

# Clear screen for clean display
clear

# Function to show menu
show_menu() {
    echo -e "${BOLD}${BLUE}╔═══════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║     POCKET IDE MOBILE         ║${NC}"
    echo -e "${BOLD}${BLUE}╚═══════════════════════════════╝${NC}"
    echo ""
    
    # Check Claude status
    if tmux has-session -t $SESSION 2>/dev/null; then
        if tmux capture-pane -t $SESSION:0.0 -p 2>/dev/null | tail -1 | grep -q "claude>"; then
            echo -e "${GREEN}$ICON_CLAUDE Claude: Ready${NC}"
        else
            echo -e "${YELLOW}$ICON_CLAUDE Claude: Working...${NC}"
        fi
    else
        echo -e "${RED}$ICON_CLAUDE Session: Not running${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}Quick Actions:${NC}"
    echo "  ${BOLD}1${NC}) $ICON_STATUS View Dashboard"
    echo "  ${BOLD}2${NC}) $ICON_RUN  Run Command"
    echo "  ${BOLD}3${NC}) $ICON_CLAUDE Show Claude Output"
    echo "  ${BOLD}4${NC}) $ICON_TERMINAL Switch to Terminal"
    echo "  ${BOLD}5${NC}) $ICON_CLEAR Clear Claude Screen"
    echo "  ${BOLD}6${NC}) $ICON_KILL Stop Current Task"
    echo "  ${BOLD}7${NC}) 🔄 Restart Claude"
    echo "  ${BOLD}8${NC}) 📱 Mobile Tips"
    echo "  ${BOLD}9${NC}) 🚪 Exit Menu"
    echo ""
    echo -n "Choose [1-9]: "
}

# Function to run command with feedback
run_command() {
    echo -e "\n${BLUE}Enter command for Claude:${NC}"
    echo -n "> "
    read -r cmd
    if [ -n "$cmd" ]; then
        tmux send-keys -t $SESSION:0.0 "$cmd" Enter
        echo -e "${GREEN}✅ Command sent!${NC}"
        sleep 1
    fi
}

# Function to show mobile tips
show_tips() {
    clear
    echo -e "${BOLD}${BLUE}📱 Mobile Tips${NC}"
    echo "==============="
    echo ""
    echo "${BOLD}Termius Gestures:${NC}"
    echo "  • Swipe right: Show keyboard"
    echo "  • Two-finger tap: Paste"
    echo "  • Pinch: Zoom in/out"
    echo ""
    echo "${BOLD}Quick Commands:${NC}"
    echo "  • Just type 's' for status"
    echo "  • Type 'r' then your command"
    echo "  • Type 'd' for dashboard"
    echo ""
    echo "${BOLD}Pro Tips:${NC}"
    echo "  • Use Tailscale for best connection"
    echo "  • Enable Termius snippets for common commands"
    echo "  • Set font size to 14pt minimum"
    echo ""
    echo "Press Enter to continue..."
    read -r
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            clear
            ~/.pocket-ide/bin/pocket-quick.sh d
            echo -e "\n${BOLD}Press Enter to continue...${NC}"
            read -r
            ;;
        2)
            run_command
            ;;
        3)
            clear
            echo -e "${BOLD}${BLUE}Claude Output (last 30 lines):${NC}"
            echo "=============================="
            tmux capture-pane -t $SESSION:0.0 -p | tail -30
            echo -e "\n${BOLD}Press Enter to continue...${NC}"
            read -r
            ;;
        4)
            echo -e "${GREEN}Switching to terminal pane...${NC}"
            tmux select-pane -t $SESSION:0.1
            tmux attach-session -t $SESSION
            ;;
        5)
            tmux send-keys -t $SESSION:0.0 "clear" Enter
            echo -e "${GREEN}✅ Claude screen cleared${NC}"
            sleep 1
            ;;
        6)
            tmux send-keys -t $SESSION:0.0 C-c
            echo -e "${YELLOW}🛑 Sent interrupt signal${NC}"
            sleep 1
            ;;
        7)
            echo -e "${YELLOW}Restarting Claude...${NC}"
            tmux send-keys -t $SESSION:0.0 C-c
            sleep 0.5
            tmux send-keys -t $SESSION:0.0 "claude" Enter
            echo -e "${GREEN}✅ Claude restarted${NC}"
            sleep 2
            ;;
        8)
            show_tips
            ;;
        9|q|Q|exit)
            echo -e "${GREEN}Thanks for using Pocket IDE! 👋${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            sleep 1
            ;;
    esac
    clear
done