# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "22f6736e628958f05222ddaadd7df7818fe8f59d";
    ref = "release-20.09";
  };
in
{
  imports = [
    "${home-manager}/nixos"
  ];

  # Don't forget to set a password with ‘passwd’.
  users.extraGroups.stears = {
    gid = 1000;
  };

  users.users.stears = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "wireshark" "video" "vboxusers" ];
    createHome = true;
    home = "/home/stears";
    uid = 1000;
    group = "stears";
    shell = "${pkgs.zsh}/bin/zsh";

    openssh.authorizedKeys.keys = [
      (import ../keys/pubkey-philip-yk.nix)
      (import ../keys/pubkey-philip-kp2a.nix)
      (import ../keys/pubkey-philip-old.nix)
      (import ../keys/pubkey-philip-iphone.nix)
    ];
  };

  home-manager.users.stears = import ./hm.nix { inherit pkgs lib; };
}
