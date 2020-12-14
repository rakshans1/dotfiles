#!/bin/sh

set -e

if tmux has-session -t dotfiles 2> /dev/null; then
  tmux attach -t dotfiles
  exit
fi

tmux new-session -d -s dotfiles -n editor
tmux send-keys -t dotfiles:editor "v " Enter
tmux split-window -t dotfiles:editor -v
tmux send-keys -t dotfiles:editor "gst" Enter
tmux split-window -t dotfiles:editor -h
tmux resize-pane -t dotfiles:1.2 -D 5
tmux attach -t dotfiles:editor.top
