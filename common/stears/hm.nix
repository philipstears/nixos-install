# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, lib, ... }:

let
  private = import ../private { inherit pkgs; };

  tmuxPlugins = with pkgs.tmuxPlugins; [
    resurrect
    sessionist
  ];

  modules = [
    ./hm-nixos.nix
    ./hm-tmux.nix
    ./hm-emacs.nix
    ./hm-neovim.nix
    ./hm-git.nix
    ./hm-zsh.nix
    ./hm-xmonad.nix
    ./hm-direnv.nix
  ];

  moduleResults = builtins.map runModule modules;

  runModule = module: import module { inherit pkgs lib; };

  combined = builtins.foldl' mergeResult {} moduleResults;

  # This is a deep set merge, right-hand-side wins,
  # it's not perfect but it should do
  mergeResult =
    moduleResult: acc:
      lib.recursiveUpdate acc moduleResult;

in
  combined

