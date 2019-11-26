# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

{

  # Packages
  home.packages = with pkgs; [

    # GNU > BSD :)
    coreutils

    # Useful for system administration
    htop
    wget

    # Development
    gitAndTools.tig
  ];

  # Configuration
  imports = [
    ../../common/stears/hm-tmux.nix
    ../../common/stears/hm-neovim.nix
    ../../common/stears/hm-git.nix
    ../../common/stears/hm-emacs.nix
    ../../common/stears/hm-zsh.nix
    ../../common/stears/hm-direnv.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
