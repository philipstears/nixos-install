# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, ... }:

{
  home.packages = with pkgs; [

    # Misc Utils
    bat
    silver-searcher

    # Learning
    anki
  ];
}

