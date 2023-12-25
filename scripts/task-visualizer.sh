#!/bin/bash
#

tmux split-window -h
tmux split-window
tmux resize-pane -U 14
tmux resize-pane -R 5
tmux send-keys -t0 "btop" Enter
tmux send-keys -t1 "while true;do task next limit:5;sleep 2;done" Enter
tmux send-keys -t2 "while true;do task burndown.daily;sleep 3;done" Enter

tmux rename-window "tasks"
tmux new-window




