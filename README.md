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

Then press `Prefix + I` to install.

### Manual

```bash
git clone https://github.com/abdrahmandiab/tmux-shift-arrow-select ~/.tmux/plugins/tmux-shift-arrow-select
~/.tmux/plugins/tmux-shift-arrow-select/shift-arrow-select.tmux
```

## Keybindings

| Key | Action |
|-----|--------|
| `Shift+Left` | Start/extend selection leftward |
| `Shift+Right` | Start/extend selection rightward |
| `Shift+Up` | Start/extend selection upward |
| `Shift+Down` | Start/extend selection downward |

Moving the cursor back toward the anchor shrinks the selection, exactly as in a text editor.

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
