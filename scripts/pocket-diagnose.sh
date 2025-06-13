#!/bin/bash
# Pocket IDE Diagnostic and Repair Script

SESSION="vibecode"

# Colors
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

echo "${bold}Pocket IDE Diagnostic${normal}"
echo "===================="
echo ""

# Check if session exists
if ! tmux has-session -t $SESSION 2>/dev/null; then
    echo "${red}[ERROR]${normal} No tmux session found!"
    echo ""
    echo "Fix: Run ${green}pocket-ide start${normal} to create session"
    exit 1
fi

echo "${green}[OK]${normal} Session '$SESSION' exists"

# Check windows
echo ""
echo "${bold}Windows:${normal}"
tmux list-windows -t $SESSION | while read line; do
    echo "  $line"
done

# Check panes in main window
echo ""
echo "${bold}Panes in main window:${normal}"
tmux list-panes -t $SESSION:0 2>/dev/null | while read line; do
    echo "  $line"
done || echo "${red}  No panes found!${normal}"

# Count panes
PANE_COUNT=$(tmux list-panes -t $SESSION:0 2>/dev/null | wc -l || echo 0)

if [ "$PANE_COUNT" -lt 2 ]; then
    echo ""
    echo "${yellow}[WARNING]${normal} Expected 2 panes, found $PANE_COUNT"
    echo ""
    echo "${bold}Attempting to repair...${normal}"
    
    # If only one pane, split it
    if [ "$PANE_COUNT" -eq 1 ]; then
        echo "Creating missing terminal pane..."
        # Use current directory or home
        local work_dir="${PWD:-$HOME}"
        tmux split-window -h -t $SESSION:0 -c "$work_dir"
        tmux resize-pane -t $SESSION:0.0 -x 60%
        
        # Check if Claude is running in pane 0
        if ! tmux capture-pane -t $SESSION:0.0 -p | tail -1 | grep -q "claude>"; then
            echo "Starting Claude in left pane..."
            tmux send-keys -t $SESSION:0.0 'claude' Enter
        fi
        
        echo "${green}[FIXED]${normal} Session structure repaired!"
    else
        echo "${red}[ERROR]${normal} No panes found. Recreating session..."
        tmux kill-session -t $SESSION 2>/dev/null
        pocket-ide start
        echo "${green}[FIXED]${normal} Session recreated!"
    fi
else
    echo "${green}[OK]${normal} Found $PANE_COUNT panes"
fi

# Test each pane
echo ""
echo "${bold}Testing pane access:${normal}"
for pane in 0 1; do
    if tmux capture-pane -t $SESSION:0.$pane -p >/dev/null 2>&1; then
        echo "${green}[OK]${normal} Can access pane $pane"
    else
        echo "${red}[ERROR]${normal} Cannot access pane $pane"
    fi
done

# Check Claude status
echo ""
echo "${bold}Claude Status:${normal}"
if tmux capture-pane -t $SESSION:0.0 -p 2>/dev/null | tail -1 | grep -q "claude>"; then
    echo "${green}[OK]${normal} Claude is ready"
else
    last_line=$(tmux capture-pane -t $SESSION:0.0 -p 2>/dev/null | tail -1)
    if [ -n "$last_line" ]; then
        echo "${yellow}[...]${normal} Claude might be working or needs restart"
        echo "      Last line: $last_line"
    else
        echo "${red}[ERROR]${normal} Claude not running"
        echo "      Fix: Run ${green}rs${normal} to restart Claude"
    fi
fi

echo ""
echo "${bold}Summary:${normal}"
echo "--------"
if [ "$PANE_COUNT" -ge 2 ]; then
    echo "${green}✓ Session structure looks good${normal}"
    echo ""
    echo "If commands still don't work, try:"
    echo "  1. ${green}pocket${normal} - Reattach to session"
    echo "  2. ${green}rs${normal} - Restart Claude"
    echo "  3. ${green}tmux kill-session -t vibecode${normal} then ${green}pocket-ide start${normal} - Full reset"
else
    echo "${yellow}⚠ Session was repaired. Try your commands again!${normal}"
fi