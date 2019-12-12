# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, ... }:

{
  # Automatically adds lorri to home.packages
  services.lorri = {
    enable = true;
  };
}

