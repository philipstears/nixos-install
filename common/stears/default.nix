# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "9781f3766de7293a67aa8098edb5dbe367939b36";
    ref = "master";
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
      (import ./files/pubkey-philip-yk.nix)
      (import ./files/pubkey-philip-kp2a.nix)
      (import ./files/pubkey-philip-old.nix)
    ];
  };

  home-manager.users.stears = import ./hm.nix { inherit pkgs lib; };
}
