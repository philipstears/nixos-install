# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, lib, ... }:

let
  tmuxPlugins = with pkgs.tmuxPlugins; [
    resurrect
    sessionist
  ];
in
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

      ${lib.concatStrings (map (x: "run-shell ${x.rtp}\n") tmuxPlugins)}
    '';

    # Don't use tmux-sensible for now because it tries
    # using reattach-to-user-namespace which causes a
    # warning in every pane on Catalina
    sensibleOnTop = false;

    # Assumes the presence of a /run directory, which we don't have on
    # macOS
    secureSocket = false;
  };
}

