# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, ... }:

let
  standardPlugins = pkgs.vimPlugins;
  customPlugins = import ./vim-plugins.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    universal-ctags
  ];

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
      standardPlugins.tagbar
      # standardPlugins.vim-gutentags

      # Specific Languages
      customPlugins.elm-vim
      customPlugins.purescript-vim
      customPlugins.vim-jsx
      standardPlugins.typescript-vim
      standardPlugins.vim-markdown
      standardPlugins.vim-nix

      # Rust Bits
      standardPlugins.ale
      standardPlugins.deoplete-nvim
      standardPlugins.deoplete-rust
      standardPlugins.vim-toml

      # Colour Schemes
      customPlugins.vim-colorschemes
      customPlugins.vim-solarized
    ];
    extraConfig = (builtins.readFile ./files/vim-init.vim);
  };
}

