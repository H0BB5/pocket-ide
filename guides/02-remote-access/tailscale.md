# Tailscale Setup Guide - True Remote Access 🌐

> Stop typing IP addresses. Start coding from anywhere.

## Why Tailscale?

Before diving into setup, let's be clear about why Tailscale is THE solution for Pocket IDE:

- **🚀 Zero Configuration**: No port forwarding, no firewall rules, no VPN configs
- **🔐 Secure by Default**: End-to-end encrypted, zero-trust network
- **📱 Works Everywhere**: Coffee shop WiFi, cellular data, behind corporate firewalls
- **🆓 Free for Personal Use**: Up to 20 devices, perfect for personal dev setup
- **🏷️ Human-Friendly Names**: Connect to 'my-macbook' not '100.64.x.x'

## Quick Setup (5 minutes)

### 1. Install Tailscale on Your Mac

```bash
# Install via Homebrew
brew install tailscale

# Start Tailscale
sudo tailscale up

# Give your machine a memorable name
sudo tailscale up --hostname "pocket-mac"
```

### 2. Install Tailscale on Your Phone

- **iOS**: [App Store](https://apps.apple.com/us/app/tailscale/id1470499037)
- **Android**: [Play Store](https://play.google.com/store/apps/details?id=com.tailscale.ipn)

Login with the same account (Google, Microsoft, or email).

### 3. Update Pocket IDE for Tailscale

Run this to upgrade your Pocket IDE with Tailscale support:

```bash
curl -sSL https://raw.githubusercontent.com/H0BB5/pocket-ide/main/scripts/tailscale-upgrade.sh | bash
```

### 4. Connect from Your Phone

In Termius:
1. Add new host
2. Hostname: `pocket-mac` (or whatever you named it)
3. Username: Your Mac username
4. Port: 22

That's it! You're connected from anywhere. 🎉

## Advanced Configuration

### 🚄 Enable MagicDNS

MagicDNS lets you use hostnames instead of IPs:

```bash
# In Tailscale admin panel, enable MagicDNS
# Then you can use: ssh username@pocket-mac
```

### 🔋 Battery-Friendly Mobile Settings

On your phone's Tailscale app:
1. Settings → "Use Tailscale DNS" → Off (saves battery)
2. Settings → "Allow LAN Access" → On (for home network fallback)

### 🛡️ Enhanced Security

```bash
# 1. Restrict SSH to Tailscale only
sudo nano /etc/ssh/sshd_config

# Add this line:
ListenAddress 100.64.0.0/10  # Tailscale CGNAT range

# 2. Restart SSH
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load /System/Library/LaunchDaemons/ssh.plist
```

## The Ultimate Mobile Experience

### 📱 One-Tap Connection Script

Create `~/.ssh/config` on your phone (via Termius):

```
Host pocket
    HostName pocket-mac
    User your-username
    RequestTTY yes
    RemoteCommand tmux attach -t vibecode || tmux new -s vibecode
```

Now just type `ssh pocket` and you're instantly in your session!

### 🎯 Ultra-Short Commands

After running the Tailscale upgrade, you get these 2-letter commands:

```bash
# Status commands
s  - Show Claude status
l  - Show last 10 lines
ll - Show last 50 lines

# Action commands  
r  - Run command (r "create a python script")
c  - Clear screen
k  - Kill current process
rs - Restart Claude

# Navigation
1  - Switch to Claude pane
2  - Switch to terminal pane
3  - Switch to monitor window

# Quick actions
h  - Show help menu
d  - Show dashboard (both panes status)
```

### 🔔 Mobile Notifications (Experimental)

Get notified when Claude finishes a task:

```bash
# In your ~/.pocket-ide/config
ENABLE_NOTIFICATIONS=true
PUSHOVER_TOKEN=your-token
```

## Troubleshooting

### "Can't connect via Tailscale"

1. Check both devices are online:
   ```bash
   tailscale status
   ```

2. Verify SSH is listening:
   ```bash
   sudo lsof -i :22
   ```

3. Test connection:
   ```bash
   tailscale ping pocket-mac
   ```

### "Connection drops when switching networks"

Install Mosh for persistent connections:

```bash
# On Mac
brew install mosh

# Connect with
mosh --ssh="ssh -p 22" pocket-mac -- tmux attach -t vibecode
```

### "Tailscale using too much battery"

- Disable "Use Tailscale DNS" on mobile
- Set Tailscale to "On Demand" mode
- Use "Exit Node" feature sparingly

## Quick Reference Card

Save this to your phone for easy access:

```
🚀 POCKET IDE QUICK REFERENCE 🚀

Connect: ssh pocket
Status:  s
Run:     r "your command"
Clear:   c
Help:    h

Panes:   1=Claude 2=Term 3=Monitor
Kill:    k (stops current)
Restart: rs (restart Claude)

Dashboard: d (see everything)
```

## Pro Tips

1. **Bathroom Mode™**: Set Termius to auto-connect and run `d` (dashboard) on connection
2. **Coffee Shop Mode**: Use Tailscale's exit nodes for extra privacy
3. **Airplane Mode**: Tailscale works over any internet connection, even slow ones
4. **Boss Mode**: Name your session something boring like "reports"

## What's Next?

Now that you have true remote access:

1. Set up [Mobile Optimizations](../04-mobile-optimization.md)
2. Configure [MCP Integration](../03-mcp-integration.md)
3. Try [Advanced Workflows](../05-advanced-workflows.md)

---

<p align="center">
Never let a bathroom break interrupt your flow again 🚽➡️💻
</p>