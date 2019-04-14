{ pkgs
}:

with pkgs;

stdenv.mkDerivation {
  name = "jump";

  src = ./sources/jump;

  phases = [ "installPhase" "fixupPhase" ];

  installPhase =
    ''
        mkdir -p $out/bin
        ln -s $src/jump $out/bin

        mkdir -p $out/share/bash-completion/completions
        ln -s $src/jump-completion.sh $out/share/bash-completion/completions/jump

        mkdir -p $out/share/zsh/vendor-completions
        ln -s $src/zsh-functions/_jump $out/share/zsh/vendor-completions/_jump

        substitute \
          $src/jump-refresh \
          $out/bin/jump-refresh \
          --replace "awk" "${gawk}/bin/awk"

        chmod +x $out/bin/jump-refresh
    '';
  }


