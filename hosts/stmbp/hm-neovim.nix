# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      nerdtree
      ctrlp
      editorconfig-vim
      vim-surround
      vim-fugitive
      typescript-vim
    ];
    extraConfig = (builtins.readFile ../../common/stears/files/vimrc);
  };
}

