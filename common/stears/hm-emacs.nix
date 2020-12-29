# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
    extraPackages = (
      epkgs:
      [
        epkgs.melpaPackages.use-package

        # General things
        epkgs.melpaPackages.ag
        epkgs.melpaPackages.evil
        epkgs.melpaPackages.neotree
        epkgs.melpaPackages.projectile
        epkgs.melpaPackages.company
        epkgs.melpaPackages.magit
        epkgs.melpaPackages.rainbow-delimiters
        epkgs.melpaPackages.editorconfig
        epkgs.melpaPackages.linum-relative
        epkgs.melpaPackages.markdown-mode
        epkgs.melpaPackages.yaml-mode
        epkgs.melpaPackages.terraform-mode
        epkgs.melpaPackages.helm-ag

        epkgs.melpaPackages.pastelmac-theme
        epkgs.melpaPackages.monokai-theme

        # EDTS Requirements
        epkgs.melpaPackages.eproject
        epkgs.melpaPackages.auto-complete
        epkgs.melpaPackages.auto-highlight-symbol

        epkgs.melpaPackages.erlang
        epkgs.melpaPackages.company-erlang

        # epkgs.melpaPackages.flycheck
        # epkgs.melpaPackages.flymake-cursor

        # Web Things
        epkgs.melpaPackages.web-mode
        epkgs.melpaPackages.elm-mode
        epkgs.melpaPackages.typescript-mode

        # Rust
        epkgs.melpaPackages.rust-mode
        epkgs.melpaPackages.cargo
        epkgs.melpaPackages.toml-mode

        # PureScript
        epkgs.melpaPackages.purescript-mode
        epkgs.melpaPackages.psc-ide
        epkgs.melpaPackages.dhall-mode

        # Things Steve has and I don't
        # epkgs.melpaPackages.ace-jump-mode
        # epkgs.melpaPackages.spaceline
        # epkgs.melpaPackages.smex
      ]
      );
  };

  home.file.".emacs.d/init.el".source = ./files/emacs-init.el;
}

