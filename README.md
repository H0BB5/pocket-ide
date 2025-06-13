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
| `k` | Kill process | Stop Claude |
| `1` | Go to Claude | Switch panes |
| `2` | Go to terminal | Switch panes |
| `p` | Next pane | Cycle through |
| `fix` | Diagnose & repair | Fix broken sessions |

## 🔧 Troubleshooting

### "can't find pane" errors
Your tmux session structure is broken. Run:
```bash
fix    # Diagnose and auto-repair
```

### "sessions should be nested with care"
This happens when trying to attach while already in tmux. Use:
- `1`, `2`, `3` - Switch panes directly (after Tailscale upgrade)
- `p` - Cycle to next pane
- Or exit tmux first with `Ctrl+b d`

### "Claude command not found"
Download Claude Code from: https://claude.ai/download

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