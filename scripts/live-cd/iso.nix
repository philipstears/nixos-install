{config, pkgs, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  users.users.root.openssh.authorizedKeys.keys = [
    (import ../../common/stears/files/pubkey-philip-yk.nix)
    (import ../../common/stears/files/pubkey-steve.nix)
    (import ../../common/stears/files/pubkey-james.nix)
    (import ../../common/stears/files/pubkey-adrian.nix)
  ];
}

