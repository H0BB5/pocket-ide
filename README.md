# Pocket IDE 📱💻

> Never interrupt your flow again. Code from anywhere - even the bathroom.

## What is Pocket IDE?

Pocket IDE is a guide for setting up a persistent, remotely accessible development environment that lets you continue working with your IDE and Claude Code from your smartphone. Perfect for those moments when you need to step away but want to keep your development momentum going.

### 🎯 Primary Use Cases

- **Quick Tasks on the Go**: Step away for a bathroom break or errand? Continue running Claude tasks from your phone
- **Persistent Environment**: No setup/prep needed when switching devices - your environment is always ready
- **Seamless Continuity**: Start a task on your desktop, check progress on your phone, return to find everything done

## 🚀 Quick Start (Local Network Only)

This gets you running in ~10 minutes on your home network:

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
   - macOS: Apple Menu → About This Mac → More Info → System Report → Network
   - Or run: `ipconfig getifaddr en0`

5. **Setup Mobile Access**
   - Download [Termius](https://termius.com/) on your Mac and phone
   - Add new host in Termius with your Mac's IP address
   - Use your Mac username/password for SSH

6. **Connect From Your Phone**
   - Open Termius on your phone
   - Connect to your Mac
   - Run: `tmux attach -t vibecode`
   - You're now controlling Claude Code from your phone! 🎉

## 📖 Table of Contents

- [Full Setup Guide](#full-setup-guide)
  - [Local Network Setup](#local-network-setup)
  - [Remote Access Setup](#remote-access-setup)
  - [MCP Server Integration](#mcp-server-integration)
  - [Mobile Optimizations](#mobile-optimizations)
- [Advanced Features](#advanced-features)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)

## Full Setup Guide

### Local Network Setup

<details>
<summary>📋 Detailed Local Setup Instructions</summary>

#### Prerequisites Check
```bash
# Check if you have required tools
command -v brew >/dev/null 2>&1 || echo "❌ Homebrew not installed"
command -v tmux >/dev/null 2>&1 || echo "❌ tmux not installed"
command -v claude >/dev/null 2>&1 || echo "❌ Claude Code not installed"
```

#### Enhanced tmux Configuration
Create `~/.tmux.conf`:
```bash
# Better mobile experience
set -g mouse on
set -g history-limit 10000

# Larger text for mobile
set -g status-left-length 30
set -g status-right-length 60

# Easy pane switching with Alt+Arrow
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
```

#### Persistent Session Script
Create `~/start-pocket-ide.sh`:
```bash
#!/bin/bash
SESSION="vibecode"

# Check if session exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  # Create new session with two panes
  tmux new-session -d -s $SESSION -n 'main'
  
  # Split horizontally
  tmux split-window -h -t $SESSION:0
  
  # Left pane: Claude Code
  tmux send-keys -t $SESSION:0.0 'claude' Enter
  
  # Right pane: Project directory
  tmux send-keys -t $SESSION:0.1 'cd ~/projects && clear' Enter
  
  echo "✅ Pocket IDE session created!"
else
  echo "📱 Pocket IDE session already running!"
fi

# Show how to attach
echo "To attach: tmux attach -t $SESSION"
```

Make it executable: `chmod +x ~/start-pocket-ide.sh`

</details>

### Remote Access Setup

<details>
<summary>🌐 Access from Anywhere (Not Just Home)</summary>

#### Option 1: Tailscale (Recommended for Beginners)

**Why Tailscale?**
- ✅ Free for personal use
- ✅ Works instantly through any network
- ✅ No port forwarding needed
- ✅ Encrypted end-to-end

**Setup:**
```bash
# Install on Mac
brew install tailscale

# Start Tailscale
sudo tailscale up

# Get your Tailscale IP
tailscale ip -4
```

**On your phone:**
1. Install Tailscale app
2. Login with same account
3. Your Mac appears as a device
4. Use Tailscale IP in Termius instead of local IP

#### Option 2: Cloudflare Tunnel (Advanced)

**Why Cloudflare?**
- ✅ No app needed on phone
- ✅ Can use custom domain
- ✅ Works through any firewall
- ❌ More complex setup

**Setup Guide:** [Coming Soon - See Issue #2]

#### Option 3: Quick Testing with ngrok

```bash
# Install ngrok
brew install ngrok

# Expose SSH (temporary URL)
ngrok tcp 22
```

</details>

### MCP Server Integration

<details>
<summary>🔗 Connect Claude Code to Your IDE</summary>

**What is MCP?**
Model Context Protocol lets Claude Code access your filesystem and tools.

**Setup Steps:**

1. **Configure Claude Desktop**
   
   Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:
   ```json
   {
     "mcpServers": {
       "filesystem": {
         "command": "npx",
         "args": [
           "-y",
           "@modelcontextprotocol/server-filesystem",
           "~/projects"
         ]
       }
     }
   }
   ```

2. **Install MCP Server**
   ```bash
   npm install -g @modelcontextprotocol/server-filesystem
   ```

3. **Restart Claude Desktop**
   - Quit Claude Desktop completely
   - Reopen and check MCP connection icon

4. **Test Integration**
   ```bash
   # In Claude Code, try:
   # "Can you see the files in my projects folder?"
   ```

**Cursor Integration:** [Coming Soon - See Issue #3]

</details>

### Mobile Optimizations

<details>
<summary>📱 Better Mobile Experience</summary>

#### Termius Settings
1. **Keyboard Shortcuts**
   - Settings → Keychain → Add useful shortcuts
   - Map "Ctrl+C" to accessible button
   - Add tmux prefix key as shortcut

2. **Font Size**
   - Settings → Appearance → Font Size: 14pt minimum

3. **Color Scheme**
   - Use high contrast theme
   - Enable "Vibrant" colors

#### tmux Mobile Commands
```bash
# Create mobile-friendly aliases
echo "alias ta='tmux attach -t vibecode'" >> ~/.zshrc
echo "alias tl='tmux list-sessions'" >> ~/.zshrc
echo "alias tn='tmux new -s'" >> ~/.zshrc
```

#### Quick Actions Script
Create `~/pocket-commands.sh`:
```bash
#!/bin/bash
# Common commands for mobile

case "$1" in
  "status")
    echo "=== Claude Status ==="
    tmux capture-pane -t vibecode:0.0 -p | tail -20
    ;;
  "run")
    shift
    tmux send-keys -t vibecode:0.0 "$*" Enter
    ;;
  "clear")
    tmux send-keys -t vibecode:0.0 "clear" Enter
    ;;
  *)
    echo "Usage: pocket [status|run|clear]"
    ;;
esac
```

</details>

## Advanced Features

### 🔐 Security Hardening

<details>
<summary>Secure Your Setup</summary>

1. **SSH Key Authentication**
   ```bash
   # Generate key pair
   ssh-keygen -t ed25519 -C "pocket-ide"
   
   # Copy to Mac
   ssh-copy-id -i ~/.ssh/id_ed25519 username@mac-ip
   ```

2. **Disable Password Auth**
   Edit `/etc/ssh/sshd_config`:
   ```
   PasswordAuthentication no
   PubkeyAuthentication yes
   ```

3. **Change SSH Port**
   ```
   Port 2222  # Or any non-standard port
   ```

</details>

### 🔄 Persistent Connections

<details>
<summary>Never Lose Connection</summary>

**Using Mosh (Mobile Shell)**
```bash
# Install mosh
brew install mosh

# Connect with mosh instead of SSH
mosh username@ip -- tmux attach -t vibecode
```

Benefits:
- Survives network changes
- Handles high latency
- Instant reconnection

</details>

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

### ✅ Phase 1: Local Network (Current)
- [x] Basic tmux + SSH setup
- [x] Mobile access via Termius
- [x] Persistent sessions

### 🔄 Phase 2: Remote Access
- [ ] Tailscale integration guide
- [ ] Cloudflare Tunnel setup
- [ ] Security best practices

### 🚧 Phase 3: Enhanced Integration
- [ ] MCP server configuration
- [ ] Cursor + Claude Code integration
- [ ] Automated setup scripts

### 🔮 Phase 4: Advanced Features
- [ ] Synology NAS setup guide
- [ ] Multi-user environment
- [ ] Container-based development
- [ ] Voice control integration

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