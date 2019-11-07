# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

let
  private = import ../private { inherit pkgs; };
in
{
  home-manager.users.stears = {
    home.file.".xmobarrc".source = ./files/xmobarrc;
  };
}

