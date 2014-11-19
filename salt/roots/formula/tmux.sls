#
# -*- coding: utf-8 -*-
#
# Copyright © 2014 Contributors
# See LICENSE for details
#
tmux:
  pkg.latest:
    - name: tmux
  file.managed:
    - name: /root/.tmux.conf
    - contents: |
        set bell-action none
        setw -g mode-keys vi
        # Override default prefix
        # set to ^X
        unbind C-x
        set -g prefix ^B
        bind b send-prefix
        bind n next
        bind p previous-window
        bind l last
        bind r source-file ~/.tmux.conf
        unbind % # Remove default binding
        bind | split-window -h
        bind - split-window -v
        bind-key C-p pipe-pane -o 'cat >>~/tmux/output.#W.#I-#P'
        set-option -g history-limit 5000
        set -g status-left '#[fg=black]#(whoami)@#H#[default]'
        set -g status-right '#[fg=blue][%H:%M]#[default]'
        setw -g monitor-activity on
        set -g visual-activity on
