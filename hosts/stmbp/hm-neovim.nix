# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

let
  customPlugins = import ./vim-plugins.nix { inherit pkgs; };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [

      # Useful packages provided from nixpkgs
      vim-nix
      vim-airline
      nerdtree
      ctrlp
      editorconfig-vim
      vim-surround
      vim-fugitive
      typescript-vim

      # Other packages of a more manual nature
      customPlugins.vim-colorschemes
    ];
    extraConfig = (builtins.readFile ../../common/stears/files/vimrc);
  };
}

