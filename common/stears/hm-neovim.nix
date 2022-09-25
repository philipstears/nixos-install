# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, lib, ... }:

let
  standardPlugins = pkgs.vimPlugins;
  customPlugins = import ./vim-plugins.nix { inherit pkgs; };

  pluginGit = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };
  plugin = pluginGit "HEAD";

  # nixpkgs_latest =
  #   import (builtins.fetchGit {
  #     name = "nixpkgs-pinned";
  #     url = "https://github.com/NixOS/nixpkgs.git";
  #     rev = "43152ffb579992dc6e0e55781436711f7bdfab1e";
  #     ref = "master";
  #   }) {};

in
{
  home.packages = with pkgs; [
    universal-ctags
  ];

  home.file.".config/nvim/codelldb".source = pkgs.vscode-extensions.vadimcn.vscode-lldb;
  home.file.".config/nvim/init-extra.lua".source = ./files/vim-init-extra.lua;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # package = nixpkgs_latest.neovim-unwrapped;
    plugins = [

      # Global Plugins
      standardPlugins.ack-vim
      standardPlugins.ctrlp
      standardPlugins.editorconfig-vim
      standardPlugins.nerdtree
      standardPlugins.vim-surround
      standardPlugins.vim-easy-align
      # standardPlugins.vim-fugitive
      standardPlugins.vim-airline
      standardPlugins.tagbar
      # standardPlugins.vim-gutentags
      # standardPlugins.indentLine

      # Specific Languages
      customPlugins.elm-vim
      customPlugins.purescript-vim
      standardPlugins.vim-jsx-pretty
      standardPlugins.yats-vim
      standardPlugins.typescript-vim
      standardPlugins.vim-markdown
      standardPlugins.vim-nix
      standardPlugins.verilog_systemverilog-vim

      # Generic LSP help
      (plugin "neovim/nvim-lspconfig")
      (plugin "nvim-lua/lsp_extensions.nvim")

      # Generic debug help tools
      (plugin "nvim-lua/popup.nvim")
      (plugin "nvim-lua/plenary.nvim")
      (plugin "nvim-telescope/telescope.nvim")

      # The actual debugger
      (plugin "mfussenegger/nvim-dap")

      # Extensions for debugger
      (plugin "rcarriga/nvim-dap-ui")
      (plugin "theHamsta/nvim-dap-virtual-text")

      # Rust
      (plugin "simrat39/rust-tools.nvim")
      standardPlugins.vim-toml

      # Completion
      (plugin "hrsh7th/nvim-cmp")
      (plugin "hrsh7th/cmp-nvim-lsp")
      (plugin "hrsh7th/cmp-vsnip")
      (plugin "hrsh7th/cmp-path")
      (plugin "hrsh7th/cmp-buffer")
      (plugin "hrsh7th/vim-vsnip")

      # Rainbow parens
      # (plugin "p00f/nvim-ts-rainbow")
      # (plugin "luochen1990/rainbow")
      (plugin "frazrepo/vim-rainbow")

      # Colour Schemes
      customPlugins.vim-colorschemes
      customPlugins.vim-solarized
    ];
    extraConfig = (builtins.readFile ./files/vim-init.vim);
  };
}

