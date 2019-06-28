{ pkgs, ... }:

{
  configuration = {
    hosts = import ./sources/nixos-install-priv/hosts.nix;
  };

  packages = {
    jump = import ./jump.nix { inherit pkgs; };
    project = import ./project.nix { inherit pkgs; };
  };
}

