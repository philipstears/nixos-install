# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -sg escape-time 0
      set -g history-limit 16384

      # Enable true-color for terminal type under which tmux runs
      set -ga terminal-overrides ",xterm-256color:Tc"

      # The terminal type to surface inside of tmux
      set -g default-terminal "xterm-256color"
    '';

    # Don't use tmux-sensible for now because it tries
    # using reattach-to-user-namespace which causes a
    # warning in every pane on Catalina
    sensibleOnTop = false;
  };
}

