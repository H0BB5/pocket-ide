# Pocket IDE 📱💻

> Never interrupt your flow again. Code from anywhere - even the bathroom.

## 🚀 One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/install.sh | bash
```

## 🌟 NEW: Tailscale Integration

**Code from anywhere with ultra-short commands!** After installing Tailscale:

```bash
# Upgrade to Tailscale-enabled version
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/tailscale-upgrade.sh | bash
```

Now use single-letter commands from your phone:
- `s` - Show Claude status
- `r "create a web app"` - Run command  
- `d` - Dashboard view
- `1`, `2`, `3` - Switch panes instantly

[**Full Tailscale Setup Guide →**](guides/02-remote-access/tailscale.md)

## What is Pocket IDE?

Pocket IDE is a guide for setting up a persistent, remotely accessible development environment that lets you continue working with your IDE and Claude Code from your smartphone. Perfect for those moments when you need to step away but want to keep your development momentum going.

### 🎯 Primary Use Cases

- **Quick Tasks on the Go**: Step away for a bathroom break or errand? Continue running Claude tasks from your phone
- **Persistent Environment**: No setup/prep needed when switching devices - your environment is always ready
- **Seamless Continuity**: Start a task on your desktop, check progress on your phone, return to find everything done

## 🏃 Quick Start (10 minutes)

### Option A: Local Network Only (Quick Test)

<details>
<summary>Start coding from your phone in 10 minutes</summary>

1. **Install Prerequisites**
   ```bash
   # Install Homebrew (if not installed)
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install tmux
   brew install tmux
   ```

2. **Install Development Tools**
   - Download [Cursor](https://cursor.sh/) (or your preferred IDE)
   - Install [Claude Desktop](https://claude.ai/download) and [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

3. **Start Your Persistent Session**
   ```bash
   # Create a new tmux session
   tmux new -s vibecode
   
   # Inside tmux, start Claude Code
   claude
   ```

4. **Find Your IP Address**
   ```bash
   ipconfig getifaddr en0
   ```

5. **Connect From Your Phone**
   - Download [Termius](https://termius.com/) on your phone
   - Add host with your Mac's IP
   - Connect and run: `tmux attach -t vibecode`

</details>

### Option B: Access from Anywhere (Recommended)

<details>
<summary>Code from coffee shops, airports, anywhere with internet</summary>

1. **Run the installer**
   ```bash
   curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/install.sh | bash
   ```

2. **Install Tailscale**
   ```bash
   brew install tailscale
   sudo tailscale up --hostname "pocket-mac"
   ```

3. **Upgrade for Tailscale**
   ```bash
   curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/tailscale-upgrade.sh | bash
   ```

4. **Connect from anywhere**
   - Install Tailscale on your phone
   - In Termius, use hostname: `pocket-mac`
   - Enjoy single-letter commands!

[**Detailed Tailscale Guide →**](guides/02-remote-access/tailscale.md)

</details>

## 📖 Complete Documentation

### Setup Guides
- [Local Network Setup](guides/01-local-setup.md)
- [**Tailscale Remote Access**](guides/02-remote-access/tailscale.md) 🌟 NEW
- [Cloudflare Tunnel Setup](guides/02-remote-access/cloudflare-tunnel.md) (Coming Soon)
- [MCP Server Integration](guides/03-mcp-integration.md)
- [Mobile Optimizations](guides/04-mobile-optimization.md)

### Advanced Features
- 🔐 [Security Hardening](#security-hardening)
- 🔄 [Persistent Connections](#persistent-connections)  
- 🎯 [Ultra-Short Commands](#ultra-short-commands)
- 📱 [Mobile-First Interface](#mobile-first-interface)

## 🎯 Ultra-Short Commands

After Tailscale upgrade, use these from anywhere:

| Command | Action | Example |
|---------|--------|---------|
| `s` | Show status | Just type `s` |
| `r` | Run command | `r "create a todo app"` |
| `d` | Dashboard | See everything at once |
| `c` | Clear | Clear Claude's screen |
| `k` | Kill | Stop current task |
| `1` | Claude pane | Jump to Claude |
| `2` | Terminal | Jump to terminal |
| `h` | Help | Show all commands |

## 📱 Mobile-First Interface

New touch-friendly menu system:

```bash
# After connecting via SSH
pocket-menu  # Launch mobile interface
```

Features:
- Large touch targets
- Visual status indicators
- No special characters needed
- Gesture-friendly navigation

## Troubleshooting

### Common Issues

<details>
<summary>🔧 Connection Problems</summary>

**"Connection Refused"**
- Check if SSH is enabled: System Preferences → Sharing → Remote Login
- Verify IP address is correct
- Check firewall settings

**"tmux session not found"**
```bash
# List all sessions
tmux ls

# Create new session if needed
tmux new -s vibecode
```

**"Permission Denied"**
- Verify username/password
- Check SSH logs: `sudo log show --predicate 'process == "sshd"' --last 5m`

</details>

<details>
<summary>🔧 Claude Code Issues</summary>

**"Claude command not found"**
1. Ensure Claude Code is installed
2. Add to PATH if needed:
   ```bash
   echo 'export PATH="$PATH:/path/to/claude"' >> ~/.zshrc
   ```

**"MCP Connection Failed"**
1. Check config file syntax
2. Restart Claude Desktop
3. Check MCP server logs

</details>

## Roadmap

### ✅ Phase 1: Local Network
- [x] Basic tmux + SSH setup
- [x] Mobile access via Termius
- [x] Persistent sessions

### ✅ Phase 2: Remote Access  
- [x] Tailscale integration guide
- [x] Ultra-short commands
- [x] Mobile-optimized interface
- [ ] Cloudflare Tunnel setup
- [ ] Advanced security guide

### 🚧 Phase 3: Enhanced Integration
- [ ] Full MCP server guide
- [ ] Cursor + Claude Code bridge
- [ ] Project templates

### 🔮 Phase 4: Advanced Features
- [ ] Synology NAS setup
- [ ] Multi-user support
- [ ] Container-based setup
- [ ] Voice commands
- [ ] Mobile notifications

## Contributing

Found a better way? Have questions? Contributions welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

- 🐛 [Report Issues](https://github.com/H0BB5/pocket-ide/issues)
- 💬 [Discussions](https://github.com/H0BB5/pocket-ide/discussions)
- 📧 Contact: [your-email]

## License

MIT License - see [LICENSE](LICENSE) file for details

---

<p align="center">
Made with ❤️ for developers who can't stop coding
<br>
<em>Even in the bathroom 🚽</em>
</p>