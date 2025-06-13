# 📱 Pocket IDE Quick Reference

Save this on your phone for instant access!

## 🚀 Connection

### Termius Quick Connect
```
Host: pocket-mac
User: your-username
```

### Or via command line:
```bash
ssh pocket
```

## ⚡ Ultra-Short Commands

| Cmd | Action | Example |
|-----|--------|---------|
| `s` | Status | `s` |
| `r` | Run | `r "make a game"` |
| `d` | Dashboard | `d` |
| `c` | Clear | `c` |
| `k` | Kill task | `k` |
| `rs` | Restart Claude | `rs` |
| `h` | Help | `h` |

## 🔢 Quick Navigation

- `1` - Jump to Claude
- `2` - Jump to Terminal  
- `3` - Monitor window

## 📱 Mobile Tips

### Termius Shortcuts
1. Settings → Keychain → New Snippet
2. Add these:
   - Name: "Run", Content: `r `
   - Name: "Status", Content: `s`
   - Name: "Dashboard", Content: `d`

### Touch Gestures
- **Swipe right**: Show keyboard
- **Two-finger tap**: Paste
- **Pinch**: Zoom

## 🆘 Troubleshooting

### Session died?
```bash
pocket-ide start
```

### Claude not responding?
```bash
rs  # Restart Claude
```

### Can't connect?
1. Check Tailscale: `tailscale status`
2. Restart SSH on Mac
3. Check WiFi/cellular

## 🎯 Pro Workflow

### Morning Routine
1. Open Termius
2. Tap "pocket" host
3. Type `d` (see dashboard)
4. Type `r "continue where I left off"`

### Bathroom Break™
1. Connect
2. Type `s` (quick status)
3. If done, type `r "next task"`
4. Disconnect, wash hands 🧼

### Coffee Shop Session
1. Enable Tailscale
2. Connect to pocket
3. Type `1` for Claude
4. Work normally

## 💡 Power User Tips

### Auto-Dashboard on Connect
In Termius:
- Host Settings → Run Command
- Enter: `d`

### Voice Commands (iOS)
1. Create Siri Shortcut
2. "Hey Siri, check Claude"
3. Opens Termius → pocket

### Quick Copy Output
```bash
s | pbcopy  # Copy status to clipboard
```

---

**Remember**: The best code is written from the most comfortable position 🚽💻