# 📱 Pocket IDE Mobile Cheatsheet

## 🚀 Connect

**In Termius:**
- Host: `pocket-mac` (or your hostname)
- Username: your-mac-username

**First command after connecting:**
```bash
pocket  # Attach to session
```

## ⚡ Essential Commands

```bash
d    # Dashboard - see everything
s    # Status - what's Claude doing?
r "your command"    # Run command

1    # Jump to Claude (from terminal)
2    # Jump to terminal  
p    # Next pane (cycle)

c    # Clear screen
k    # Kill/stop current task
rs   # Restart Claude
fix  # Diagnose & repair session
```

## 🎮 When Claude is Active (Important!)

When you're in the Claude pane and Claude is running, you can't use number shortcuts. Instead:

### Use tmux commands:
- `Ctrl+b` then `→` - Switch to right pane (terminal)
- `Ctrl+b` then `←` - Switch to left pane (Claude)
- `Ctrl+b` then `q` - Show pane numbers, press number to switch
- `Ctrl+b` then `z` - Zoom current pane (full screen toggle)

### Pro tip:
Switch to terminal pane (2) first, THEN use shortcuts!

## 💡 Common Workflows

### Morning check-in
```bash
d                    # See dashboard
r "continue where I left off"
```

### Quick task
```bash
s                    # Check if ready
r "fix the login bug"
2                    # Switch to terminal (to keep shortcuts working!)
```

### Something stuck?
```bash
k                    # Kill current task (shows if Claude is idle)
rs                   # Restart Claude
r "try again"        # New command
```

### Session broken?
```bash
fix                  # Auto-diagnose and repair
# Or nuclear option:
tmux kill-session -t vibecode
pocket-ide start
```

## 🔧 Fix Common Issues

**"can't find pane" errors**
```bash
fix   # This will diagnose and repair
```

**Can't use shortcuts while Claude is active**
- Use `Ctrl+b →` to switch to terminal pane
- Or `Ctrl+b q` then press pane number
- Then shortcuts work again!

**"Claude is idle (nothing to interrupt)"**
- This means `k` found nothing to kill
- Claude is ready for new commands

**Lost?**
```bash
h     # Show help with tmux tips
keys  # Show tmux key reference
d     # Dashboard view
```

## 🎯 Pro Tips

1. **Set up Termius snippets:**
   - `run` → `r "`
   - `switch` → `Ctrl+b →`
   - `zoom` → `Ctrl+b z`

2. **Better tmux navigation:**
   - Learn `Ctrl+b` shortcuts
   - Always switch to terminal pane for shortcuts
   - Use `keys` command for reference

3. **Mobile optimizations:**
   - Enable Termius keyboard toolbar
   - Add Ctrl key to toolbar
   - Use landscape mode for more space

4. **Quick status check:**
   ```bash
   d  # Dashboard shows everything at once
   ```

---
Remember: 
- Numbers work from terminal pane
- Use `Ctrl+b` arrows when in Claude
- Type `keys` for tmux reference

**Something broken?** Just type `fix` 🔧