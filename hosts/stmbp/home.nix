# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    htop
    tmux
    vim
    wget
  ];

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
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      nerdtree
      ctrlp
    ];
    extraConfig = (builtins.readFile ../../common/stears/files/vimrc);
  };

  programs.git = {
    enable = true;
    userName  = "philipstears";
    userEmail = "philip@philipstears.com";
    signing = {
      signByDefault = true;
      key = "FA836504B26D139A";
    };
  };
}
