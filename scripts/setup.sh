#!/usr/bin/env bash

# Read user-configurable options
clipboard_cmd=$(tmux show-option -gqv "@smart-select-clipboard-cmd")
shift_arrow=$(tmux show-option -gqv "@smart-select-shift-arrow")

# Defaults
clipboard_cmd="${clipboard_cmd:-xclip -selection clipboard -in}"
shift_arrow="${shift_arrow:-on}"

copy_pipe="copy-pipe-no-clear \"$clipboard_cmd\""

# ── Persistent mouse selection (highlight stays, copies to clipboard) ──────────
# Drag
tmux bind -T copy-mode    MouseDragEnd1Pane  "send-keys -X $copy_pipe"
tmux bind -T copy-mode-vi MouseDragEnd1Pane  "send-keys -X $copy_pipe"

# Double-click: select word (root enters copy mode first)
tmux bind -T root         DoubleClick1Pane   "select-pane -t= ; copy-mode -H ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X $copy_pipe"
tmux bind -T copy-mode    DoubleClick1Pane   "select-pane ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X $copy_pipe"
tmux bind -T copy-mode-vi DoubleClick1Pane   "select-pane ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X $copy_pipe"

# Triple-click: select line
tmux bind -T copy-mode    TripleClick1Pane   "select-pane ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X $copy_pipe"
tmux bind -T copy-mode-vi TripleClick1Pane   "select-pane ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X $copy_pipe"

# ── Shift+Arrow: text-editor style keyboard selection ─────────────────────────
if [ "$shift_arrow" = "on" ]; then
    # From normal mode: enter copy mode, start selection, move
    tmux bind -T root S-Left  "copy-mode ; send-keys -X begin-selection ; send-keys -X cursor-left"
    tmux bind -T root S-Right "copy-mode ; send-keys -X begin-selection ; send-keys -X cursor-right"
    tmux bind -T root S-Up    "copy-mode ; send-keys -X begin-selection ; send-keys -X cursor-up"
    tmux bind -T root S-Down  "copy-mode ; send-keys -X begin-selection ; send-keys -X cursor-down"

    # From within copy mode: extend/shrink selection, sync clipboard on each keypress
    # (clipboard must stay current because Terminator intercepts Ctrl+Shift+C before tmux)
    for table in copy-mode copy-mode-vi; do
        tmux bind -T $table S-Left  "if-shell -F '#{selection_active}' 'send-keys -X cursor-left'  'send-keys -X begin-selection ; send-keys -X cursor-left'  ; send-keys -X $copy_pipe"
        tmux bind -T $table S-Right "if-shell -F '#{selection_active}' 'send-keys -X cursor-right' 'send-keys -X begin-selection ; send-keys -X cursor-right' ; send-keys -X $copy_pipe"
        tmux bind -T $table S-Up    "if-shell -F '#{selection_active}' 'send-keys -X cursor-up'    'send-keys -X begin-selection ; send-keys -X cursor-up'    ; send-keys -X $copy_pipe"
        tmux bind -T $table S-Down  "if-shell -F '#{selection_active}' 'send-keys -X cursor-down'  'send-keys -X begin-selection ; send-keys -X cursor-down'  ; send-keys -X $copy_pipe"
    done
fi
