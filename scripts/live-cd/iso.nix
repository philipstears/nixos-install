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
    (import ../../common/keys/pubkey-philip-yk.nix)
    (import ../../common/keys/pubkey-steve.nix)
    (import ../../common/keys/pubkey-james.nix)
    (import ../../common/keys/pubkey-adrian.nix)
  ];
}

