# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs25-nox;
    extraPackages = (
      epkgs:
      [
        epkgs.melpaPackages.use-package

        epkgs.melpaPackages.evil
        epkgs.melpaPackages.neotree
        epkgs.melpaPackages.projectile
        epkgs.melpaPackages.company
        epkgs.melpaPackages.magit
        epkgs.melpaPackages.rainbow-delimiters
        epkgs.melpaPackages.editorconfig
        epkgs.melpaPackages.ag
        epkgs.melpaPackages.linum-relative

        epkgs.melpaPackages.yaml-mode

        epkgs.melpaPackages.pastelmac-theme
        epkgs.melpaPackages.monokai-theme

        # EDTS Requirements
        epkgs.melpaPackages.eproject
        epkgs.melpaPackages.auto-complete
        epkgs.melpaPackages.auto-highlight-symbol

        epkgs.melpaPackages.erlang
        epkgs.melpaPackages.company-erlang

        epkgs.melpaPackages.elm-mode

        epkgs.melpaPackages.typescript-mode

        epkgs.melpaPackages.rust-mode
        epkgs.melpaPackages.cargo
        epkgs.melpaPackages.toml-mode

        epkgs.melpaPackages.purescript-mode
        epkgs.melpaPackages.psc-ide

        epkgs.melpaPackages.web-mode
        epkgs.melpaPackages.terraform-mode
      ]
      );
  };

  home.file.".emacs.d/init.el".source = ../../common/stears/files/emacs/init.el;
}

