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

  home.file.".config/nvim/coc-settings.json".source = ./files/coc-settings.json;

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
      standardPlugins.vim-easy-align
      standardPlugins.vim-fugitive
      standardPlugins.vim-airline
      standardPlugins.tagbar
      # standardPlugins.vim-gutentags

      # LSP
      standardPlugins.coc-nvim

      # Specific Languages
      customPlugins.elm-vim
      customPlugins.purescript-vim
      standardPlugins.vim-jsx-pretty
      standardPlugins.yats-vim
      standardPlugins.coc-tsserver
      standardPlugins.vim-markdown
      standardPlugins.vim-nix
      standardPlugins.verilog_systemverilog-vim

      # Rust Bits
      standardPlugins.coc-rls
      standardPlugins.vim-toml

      # Colour Schemes
      customPlugins.vim-colorschemes
      customPlugins.vim-solarized
    ];
    extraConfig = (builtins.readFile ./files/vim-init.vim);
  };
}

