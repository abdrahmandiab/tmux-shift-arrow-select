# tmux-shift-arrow-select

Text-editor style Shift+Arrow selection for tmux. Hold Shift and press arrow keys to start and extend a selection, just like in VS Code, Sublime Text, or any standard text editor.

## Features

- **Shift+Arrow** from normal mode enters copy mode and starts a selection immediately
- **Shift+Arrow** within copy mode extends or shrinks the selection without resetting the anchor
- Selection is synced to the system clipboard on every keypress, so terminal shortcuts like `Ctrl+Shift+C` work as expected even if your terminal intercepts them before tmux

## Requirements

- tmux >= 3.2
- Clipboard command (auto-detected):
  - macOS: `pbcopy` (built-in)
  - Wayland: `wl-copy` (from `wl-clipboard`)
  - X11/Linux: `xclip`

## Installation

### Via [TPM](https://github.com/tmux-plugins/tpm)

Add to your `~/.tmux.conf`:

```tmux
set -g @plugin 'abdrahmandiab/tmux-shift-arrow-select'
```

## Keybindings

| Key | Action |
|-----|--------|
| `Shift+Left` | Start/extend selection leftward |
| `Shift+Right` | Start/extend selection rightward |
| `Shift+Up` | Start/extend selection upward |
| `Shift+Down` | Start/extend selection downward |

Moving the cursor back toward the anchor shrinks the selection, exactly as in a text editor.

## Terminal Notes

### Apple Terminal (macOS)

Apple Terminal does not send distinct escape sequences for `Shift+Arrow` keys by default — they arrive as plain arrow keys, making them indistinguishable from unmodified presses. You need to configure custom key mappings:

1. Open **Terminal → Settings → Profiles → [your profile] → Keyboard**
2. Click **+** and add the following entries:

| Key | Modifier | Action | Send String |
|-----|----------|--------|-------------|
| `↑` | Shift | Send String | `^[[1;2A` |
| `↓` | Shift | Send String | `^[[1;2B` |
| `←` | Shift | Send String | `^[[1;2D` |
| `→` | Shift | Send String | `^[[1;2C` |

> In the Send String field, `^[` is entered by pressing the actual `Escape` key.

iTerm2 sends these sequences correctly out of the box and requires no extra configuration.

## Configuration

Add these to your `~/.tmux.conf` before the `run` line that loads TPM:

```tmux
# Disable the plugin (default: on)
set -g @shift-arrow-select "off"

# Override the clipboard command (auto-detected by default: pbcopy on macOS, wl-copy on Wayland, xclip on X11)
set -g @shift-arrow-clipboard-cmd "your-clipboard-cmd"
```

## How it works

tmux's `begin-selection` command sets the selection anchor at the current cursor position. Calling it again resets the anchor, which is why naive repeat bindings lose prior lines. This plugin checks `#{selection_active}` before each move: if a selection is already in progress, it only moves the cursor (extending/shrinking from the existing anchor); otherwise it sets the anchor first. The selected text is piped to the clipboard command after every keypress via `copy-pipe-no-clear`, which keeps the highlight visible.

## License

MIT — see [LICENSE](LICENSE).
