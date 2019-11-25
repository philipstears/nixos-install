# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

{
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

