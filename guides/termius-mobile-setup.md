# Termius Mobile Setup Guide 📱

## Fixing Ctrl+B on iPhone/Android

The `Ctrl+b` key combination often doesn't work properly on mobile. Here's how to fix it:

## Solution 1: Custom Touch Bar Keys (Recommended)

### Add Custom Keys to Termius Keyboard:

1. **Open Termius and connect** to your Pocket IDE
2. **Swipe up** to show keyboard
3. Tap the **"⋯"** (three dots) button on the keyboard toolbar
4. Tap **"Edit Keys"** or **"Customize"**
5. Add these custom keys:

#### Essential Navigation Keys:
- **Name**: "→ Pane"  
  **Value**: `\x02\x1b[C`  
  (This sends Ctrl+b then right arrow)

- **Name**: "← Pane"  
  **Value**: `\x02\x1b[D`  
  (This sends Ctrl+b then left arrow)

- **Name**: "Pane #"  
  **Value**: `\x02q`  
  (This sends Ctrl+b then q)

- **Name**: "Zoom"  
  **Value**: `\x02z`  
  (This sends Ctrl+b then z)

- **Name**: "Detach"  
  **Value**: `\x02d`  
  (This sends Ctrl+b then d)

### How to Use:
1. When in Claude pane, tap **"→ Pane"** to switch to terminal
2. When in terminal, tap **"← Pane"** to switch to Claude
3. Tap **"Pane #"** then tap `1` or `2` on keyboard
4. Tap **"Zoom"** to make current pane full screen

## Solution 2: Use Escape Sequences

If custom keys don't work, use this method:

1. Press **ESC** key
2. Press **b** 
3. Press arrow key (→ or ←)

Some Termius versions show ESC as `Esc` or `⎋` on the toolbar.

## Solution 3: Termius Snippets

Create snippets for common actions:

1. Go to Termius **Settings** → **Snippets**
2. Add these snippets:

- **Name**: "switch"  
  **Command**: Press ESC, then type: `b` then `→`

- **Name**: "zoom"  
  **Command**: Press ESC, then type: `bz`

- **Name**: "panes"  
  **Command**: Press ESC, then type: `bq`

## Solution 4: Alternative Navigation

Since tmux navigation is tricky on mobile, use these Pocket IDE commands instead:

```bash
# From terminal pane, these always work:
2    # Ensures you're in terminal (safe spot)
d    # Dashboard - see everything
s    # Status - check Claude

# To run commands without switching:
r "your command"    # Works from any pane
```

## Pro Tips for Mobile

### 1. Start in Terminal Pane
Always switch to terminal pane (2) first:
```bash
2    # Now all shortcuts work
```

### 2. Use Dashboard Often
```bash
d    # Shows everything without switching
```

### 3. Zoom for Better Viewing
When you need to see more:
- Use your "Zoom" custom key
- Or: ESC → b → z

### 4. Enable These Termius Settings

Go to **Settings** in Termius:
- **Keyboard** → **Show Extra Keys Row**: ON
- **Keyboard** → **Haptic Feedback**: ON (helps confirm taps)
- **Terminal** → **Font Size**: 14pt or larger
- **Terminal** → **Use Safe Keyboard**: OFF

### 5. Landscape Mode
Turn your phone sideways for:
- More screen space
- Easier typing
- Better visibility

## Quick Reference Card

Save these to Termius Snippets:

| Action | How to Do It |
|--------|--------------|
| Switch to terminal | Tap "→ Pane" custom key |
| Switch to Claude | Tap "← Pane" custom key |
| See all panes | Tap "Pane #" then 1 or 2 |
| Full screen | Tap "Zoom" custom key |
| Exit tmux | Tap "Detach" custom key |

## Still Stuck?

If nothing works, you can always:

1. **Detach and reattach**:
   ```bash
   # Type this literally:
   exit
   # Then:
   pocket
   ```

2. **Use the nuclear option**:
   ```bash
   tmux kill-session -t vibecode
   pocket-ide start
   ```

3. **Just use terminal pane**:
   Stay in pane 2 and use commands like `r`, `s`, `d` which work from anywhere!

---

Remember: The goal is to make mobile coding easy. If tmux navigation is too hard, just stay in the terminal pane and use Pocket IDE's commands! 🚀