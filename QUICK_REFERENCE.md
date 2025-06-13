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

1    # Jump to Claude
2    # Jump to terminal  
p    # Next pane (cycle)

c    # Clear screen
k    # Kill/stop current task
rs   # Restart Claude
fix  # Diagnose & repair session
```

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
1                    # Watch Claude work
```

### Something stuck?
```bash
k                    # Kill current task
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

**"sessions should be nested..."**
- You're already in tmux!
- Use `1`, `2`, `p` to switch
- Or detach first: `Ctrl+b d`

**Can't see output?**
```bash
s     # Show last 20 lines
l     # Show last 10 lines  
ll    # Show last 50 lines
```

**Lost?**
```bash
h     # Show help
d     # Dashboard view
w     # List windows
```

## 🎯 Pro Tips

1. **Set up Termius snippets:**
   - `run` → `r `
   - `status` → `s`
   - `dash` → `d`
   - `fix` → `fix`

2. **Quick reconnect:**
   - Save host in Termius favorites
   - Use Face ID/Touch ID

3. **Better visibility:**
   - Increase font size in Termius
   - Use landscape mode
   - Enable vibrant colors

4. **Auto-repair on connect:**
   - Add to Termius "Run Command": `d`
   - Shows dashboard immediately

---
Remember: Less typing = more coding! 🚀

**Something broken?** Just type `fix` 🔧