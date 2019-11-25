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
  ];

  # Configuration
  imports = [
    ./hm-tmux.nix
    ./hm-neovim.nix
    ./hm-git.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
