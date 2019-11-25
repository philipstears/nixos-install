# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    dotDir = ".config/zsh";
    history = {
      share = false;
    };
    shellAliases = {
      "ls" = "ls --color=tty";
    };
    sessionVariables = {};
    initExtra = ''

      # Make nix things available
      . ~/.nix-profile/etc/profile.d/nix.sh

      # Update history incrementally
      INC_APPEND_HISTORY="true"

      DISABLE_AUTO_TITLE="true"

      # Colors please
      eval "$(${pkgs.coreutils}/bin/dircolors -b)"

      # Hide default user prompt
      DEFAULT_USER=''${USER}

      # Let Java know that we're using a non-reparenting WM
      export _JAVA_AWT_WM_NONREPARENTING=1

      # Force UTF-8
      export LC_ALL=de_DE.UTF-8
      export LANG=de_DE.UTF-8

      # Use GPG for SSH
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent

    '';
    profileExtra = ''
    '';
    plugins = [];
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" ];
    };
    # NOTE: syntaxHighlighting isn't provided by home-manager
  };
}

