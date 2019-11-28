# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lorri
  ];

  services.lorri = {
    enable = true;
  };
}

