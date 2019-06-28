{ pkgs }:

with pkgs;

stdenv.mkDerivation {
  name = "project";

  src = ./sources/project;

  phases = [ "installPhase" "fixupPhase" ];

  installPhase =
    ''
        mkdir -p $out/bin
        ln -s $src/project $out/bin/project

        mkdir -p $out/share/zsh/vendor-completions
        ln -s \
          $src/_lib/zsh-functions/_project \
          $out/share/zsh/vendor-completions/_project
    '';
  }


