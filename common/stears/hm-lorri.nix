# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lorri
  ];

  # The lorri daemon isn't ready for prime-time yet, sadly
  # # Automatically adds lorri to home.packages
  # services.lorri = {
  #   enable = true;
  # };
}

