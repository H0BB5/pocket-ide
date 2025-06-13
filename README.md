# 📱 Pocket IDE

> **Continue coding from anywhere** - Access your development environment and Claude Code from your phone in seconds

## 🎯 What is Pocket IDE?

Pocket IDE lets you access your coding environment remotely from your smartphone. Whether you're grabbing coffee, in the bathroom, or running errands, you can:

- ✅ Monitor long-running tasks
- ✅ Continue Claude Code conversations
- ✅ Run tests and deployments
- ✅ Review and commit code
- ✅ Debug issues on the go

**The Goal**: Get from "I need to step away" to "I'm coding on my phone" in under 10 seconds.

## 🚀 Quick Start (Local Network Only)

This setup works immediately within your home/office network. Perfect for quick breaks.

### Prerequisites
- macOS (Windows/Linux guides coming soon)
- iPhone/Android phone
- Same WiFi network

### 30-Minute Setup

1. **Install the basics**
   ```bash
   # Install Homebrew (if not installed)
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install tmux
   brew install tmux
   ```

2. **Install your tools**
   - Download [Cursor](https://cursor.sh/) (or your preferred IDE)
   - Install [Claude Code](https://claude.ai/code) 
   - Download [Termius](https://termius.com/) on your Mac

3. **Start your coding session**
   ```bash
   # In Terminal, start a persistent session
   tmux new -s pocket
   
   # Inside tmux, start Claude Code
   claude
   ```

4. **Find your Mac's IP address**
   ```bash
   # Quick command to get your IP
   ipconfig getifaddr en0
   ```
   Or: Apple Menu → System Settings → Network → Details → TCP/IP

5. **Setup Termius on Mac**
   - Add new host
   - Enter your IP address
   - Use your Mac username/password
   - Test connection

6. **Setup Termius on Phone**
   - Download Termius ([iOS](https://apps.apple.com/app/termius-ssh-client/id549039908) / [Android](https://play.google.com/store/apps/details?id=com.server.auditor.ssh.client))
   - Sign in (same account as Mac)
   - Your host will sync automatically

7. **Connect from phone**
   - Open Termius
   - Tap your Mac host
   - Run: `tmux attach -t pocket`
   - You're in! 🎉

## ⚡ The "Bathroom Break" Workflow

Once set up, leaving your desk is simple:

1. **Before leaving** (2 seconds)
   - Your tmux session is already running
   - Just walk away!

2. **From your phone** (5 seconds)
   - Open Termius
   - Tap your saved host
   - You're back in your session

3. **Pro tip**: Save this as a Termius snippet:
   ```bash
   tmux attach -t pocket || tmux new -s pocket
   ```

## 🌐 Access From Anywhere (Coming Next)

### Phase 2: Remote Access
- **Tailscale** (Easiest) - Access from anywhere with zero config
- **Cloudflare Tunnel** (Most flexible) - No VPN needed
- **Synology NAS** (Ultimate) - Your personal cloud IDE

### Phase 3: Enhanced Features
- MCP server integration
- Split-pane workflows  
- Mobile-optimized configs
- Automated setup scripts

## 📖 Full Guides

- [📚 Detailed Local Setup](guides/01-local-setup.md)
- [🌍 Remote Access Options](guides/02-remote-access.md)
- [🤖 MCP & Claude Integration](guides/03-mcp-integration.md)
- [📱 Mobile Optimization](guides/04-mobile-optimization.md)
- [🔧 Troubleshooting](guides/05-troubleshooting.md)

## 🎬 Quick Demo

```bash
# What it looks like on your phone:
$ tmux attach -t pocket
[Claude Code] > continue implementing the user authentication...
```

## 🔒 Security Notes

⚠️ **Local setup uses password auth** - Fine for home network, but upgrade to SSH keys for remote access.

## 🗺 Roadmap

- [x] Basic local network access
- [ ] One-click setup script
- [ ] Tailscale integration guide
- [ ] Cloudflare Tunnel guide
- [ ] MCP server setup
- [ ] Synology NAS persistent environment
- [ ] VS Code Server alternative
- [ ] Windows/Linux support

## 🤝 Contributing

Have a better workflow? Found a great tool? PRs welcome!

## 📝 License

MIT - Use this however you want!

---

**Remember**: The best development environment is the one that's always accessible. Start simple, enhance as needed.
