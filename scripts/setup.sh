#!/usr/bin/env bash

# Read user-configurable options
enabled=$(tmux show-option -gqv "@shift-arrow-select")
clipboard_cmd=$(tmux show-option -gqv "@shift-arrow-clipboard-cmd")

# Defaults
enabled="${enabled:-on}"
clipboard_cmd="${clipboard_cmd:-xclip -selection clipboard -in}"

if [ "$enabled" != "on" ]; then
    exit 0
fi

copy_pipe="copy-pipe-no-clear \"$clipboard_cmd\""

# ── Shift+Arrow: text-editor style keyboard selection ─────────────────────────
# From normal mode: enter copy mode, start selection, move cursor
tmux bind -T root S-Left  "copy-mode ; send-keys -X begin-selection ; send-keys -X cursor-left"
tmux bind -T root S-Right "copy-mode ; send-keys -X begin-selection ; send-keys -X cursor-right"
tmux bind -T root S-Up    "copy-mode ; send-keys -X begin-selection ; send-keys -X cursor-up"
tmux bind -T root S-Down  "copy-mode ; send-keys -X begin-selection ; send-keys -X cursor-down"

# From within copy mode: extend/shrink selection without resetting anchor.
# Clipboard is synced on every keypress so that terminals that intercept
# Ctrl+Shift+C (e.g. Terminator) see the latest selection immediately.
for table in copy-mode copy-mode-vi; do
    tmux bind -T $table S-Left  "if-shell -F '#{selection_active}' 'send-keys -X cursor-left'  'send-keys -X begin-selection ; send-keys -X cursor-left'  ; send-keys -X $copy_pipe"
    tmux bind -T $table S-Right "if-shell -F '#{selection_active}' 'send-keys -X cursor-right' 'send-keys -X begin-selection ; send-keys -X cursor-right' ; send-keys -X $copy_pipe"
    tmux bind -T $table S-Up    "if-shell -F '#{selection_active}' 'send-keys -X cursor-up'    'send-keys -X begin-selection ; send-keys -X cursor-up'    ; send-keys -X $copy_pipe"
    tmux bind -T $table S-Down  "if-shell -F '#{selection_active}' 'send-keys -X cursor-down'  'send-keys -X begin-selection ; send-keys -X cursor-down'  ; send-keys -X $copy_pipe"
done
