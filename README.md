# Pocket IDE 📱💻

> Never interrupt your flow again. Code from anywhere - even the bathroom.

## 🚀 Quick Start

### Step 1: Basic Install (5 minutes)

```bash
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/install.sh | bash
```

This gives you:
- ✅ Local network access (connect from phone while at home)
- ✅ Basic commands: `pocket status`, `pocket run 'command'`
- ✅ Persistent tmux sessions

### Step 2: Enable Remote Access (2 minutes)

Want to code from coffee shops, airports, or anywhere? Add Tailscale:

```bash
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/tailscale-upgrade.sh | bash
```

This adds:
- 🌐 Access from anywhere with internet
- ⚡ Ultra-short commands: `s`, `r`, `d` (instead of typing long commands)
- 🔐 Secure encrypted connection
- 📱 Better mobile experience
- 🔧 Auto-repair with `fix` command

## 📱 Mobile Setup

After installation:

1. **Install on your phone:**
   - [Termius](https://termius.com/) - SSH client
   - [Tailscale](https://tailscale.com/download) - If you did Step 2

2. **Connect from Termius:**
   - **Local only**: Use your Mac's IP (find with `ipconfig getifaddr en0`)
   - **With Tailscale**: Use your hostname (e.g., `pocket-mac`)

3. **Start coding!**
   ```bash
   pocket    # Attach to session
   d         # Show dashboard
   r "create a web app"  # Run command
   ```

## ⚡ Command Reference

### After Basic Install
| Command | What it does |
|---------|--------------|
| `pocket-ide start` | Start/attach to session |
| `pocket status` | Check Claude status |
| `pocket run 'cmd'` | Send command to Claude |

### After Tailscale Upgrade (Ultra-Short)
| Command | What it does | Example |
|---------|--------------|---------|
| `s` | Show status | Just type `s` |
| `r` | Run command | `r "build a game"` |
| `d` | Dashboard | See everything |
| `c` | Clear screen | Clean up |
| `k` | Kill process | Stop Claude (smart detection) |
| `1` | Go to Claude | Switch panes (from terminal) |
| `2` | Go to terminal | Switch panes |
| `p` | Next pane | Cycle through |
| `fix` | Diagnose & repair | Fix broken sessions |
| `keys` | tmux key reference | When shortcuts don't work |

## 🎮 Important: Pane Navigation

**When Claude is active**, number shortcuts (1,2,3) won't work because input goes to Claude. Instead:

### Use tmux native commands:
- `Ctrl+b →` - Switch to right pane (terminal)
- `Ctrl+b ←` - Switch to left pane (Claude)  
- `Ctrl+b q` - Show pane numbers, then press number
- `Ctrl+b z` - Zoom current pane (toggle full screen)

💡 **Pro tip**: Switch to terminal pane first, then shortcuts work again!

Type `keys` for full tmux reference.

## 🔧 Troubleshooting

### "can't find pane" errors
Your tmux session structure is broken. Run:
```bash
fix    # Diagnose and auto-repair
```

### Can't use shortcuts while Claude is running
- You're in the Claude pane - shortcuts go to Claude
- Use `Ctrl+b →` to switch to terminal pane
- Or `Ctrl+b q` then press `2` for terminal
- Now shortcuts work again!

### "Claude is idle (nothing to interrupt)"
- The `k` command detected Claude isn't running anything
- This is normal - Claude is ready for new commands

### "sessions should be nested with care"
- You're trying to attach while already in tmux
- Just use pane switching commands instead
- Or exit tmux first with `Ctrl+b d`

### Can't connect from phone?
1. Check SSH is enabled: System Preferences → Sharing → Remote Login
2. If using Tailscale, make sure it's running on both devices
3. Try: `ssh username@hostname` to test connection

### Something really broken?
Nuclear option - full reset:
```bash
tmux kill-session -t vibecode
pocket-ide start
```

## 🎯 What is Pocket IDE?

Pocket IDE lets you run Claude Code on your Mac and control it from your phone. Perfect for:
- Quick tasks during breaks
- Checking progress while away
- Starting long-running tasks remotely

Your development environment stays persistent - start a task on desktop, check it from your phone, come back to see it completed.

## 📚 Advanced Guides

- [MCP Integration](guides/03-mcp-integration.md) - Connect Claude to your files
- [Security Setup](guides/security.md) - SSH keys and hardening
- [Tailscale Details](guides/02-remote-access/tailscale.md) - Deep dive

## License

MIT License - see [LICENSE](LICENSE) file

---

<p align="center">
Made with ❤️ for developers who can't stop coding
<br>
<em>Even in the bathroom 🚽</em>
</p>