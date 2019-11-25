# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

let
  standardPlugins = pkgs.vimPlugins;
  customPlugins = import ./vim-plugins.nix { inherit pkgs; };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = [

      # Global Plugins
      standardPlugins.ack-vim
      standardPlugins.ctrlp
      standardPlugins.editorconfig-vim
      standardPlugins.nerdtree
      standardPlugins.vim-surround
      standardPlugins.vim-fugitive
      standardPlugins.vim-airline

      # Specific Languages
      customPlugins.elm-vim
      customPlugins.purescript-vim
      customPlugins.vim-jsx
      standardPlugins.typescript-vim
      standardPlugins.vim-markdown
      standardPlugins.vim-nix

      # Colour Schemes
      customPlugins.vim-colorschemes
      customPlugins.vim-solarized
    ];
    extraConfig = (builtins.readFile ../../common/stears/files/vimrc);
  };
}

