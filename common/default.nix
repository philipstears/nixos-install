# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "4a3d01fb53f52ac83194081272795aa4612c2381";
    ref = "release-22.05";
  };

  private = import ./private { inherit pkgs; };

  # Whichever version discord says is latest
  discord_latest_version = "0.0.16";
  discord_latest = pkgs.discord.overrideAttrs (oldAttrs: {
    version = discord_latest_version;
    src = pkgs.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${discord_latest_version}/discord-${discord_latest_version}.tar.gz";
      sha256 = "1s9qym58cjm8m8kg3zywvwai2i3adiq6sdayygk2zv72ry74ldai";
    };
  });

in
{
  imports = [
    "${home-manager}/nixos"
  ];

  # Can't get this working with virtualbox
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.extraHosts = private.configuration.hosts;

  # Select internationalisation properties.
  i18n = {

    # English Language with sensible formatting
    defaultLocale = "en_DK.UTF-8";
  };

  console = {
    keyMap = "de";
  };

  # Set your time zone.
  services.timesyncd.enable = true; # the default, but explicitness is a good thing
  time.timeZone = "Europe/London";

  # Reasons:
  #   virtualbox guest extensions
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # Admin & Development Tools
    wget
    vim
    pavucontrol
    openssh
    git
    tmux
    ripgrep
    htop iotop iftop
    lftp
    tree
    bash-completion
    wireshark
    wireshark-cli
    iperf
    pv
    mbuffer
    openssl
    tcpdump
    ethtool
    traceroute
    jq
    awscli
    unzip
    dnsutils # dig
    man-pages
    pciutils usbutils
    fwupd
    shellcheck

    # Docker - until I can obviate it
    docker
    docker-gc
    docker-ls

    # General web things
    firefox-bin
    google-chrome
    skypeforlinux
    slack
    zoom-us
    teams
    discord_latest
    signal-desktop

    # Security
    gnupg
    pinentry-curses
    srm
    keepassxc

    # Desktop Env
    dconf # for the few gnome things I use, such as seahorse
    gnome3.dconf-editor
    gnome3.gnome-screenshot
    mate.mate-calc
    mate.caja
    dmenu
    xclip
    alacritty
    feh
    libreoffice-still

    # Hardware Acceleration Utilities
    libva-utils

    # System
    lm_sensors

    # User-mode File System
    fuse

    # Shared tmux helpers
    ( writeScriptBin "shared-tmux" ''
      #!${pkgs.bash}/bin/bash
      tmux -S /run/colleagues/tmux "''${@}"
    ''
    )

    # Desktop Env Support Utilities
    ( writeScriptBin "st-audio-get-master-volume" ''
      #!${pkgs.bash}/bin/bash
      amixer sget Master | awk -F '[][]' '/.*Left:/ { print $2 }'
    ''
    )

    ( writeScriptBin "st-audio-get-master-status" ''
      #!${pkgs.bash}/bin/bash
      amixer sget Master | awk -F '[][]' '/.*Left:/ { print $4 }'
    ''
    )

    ( writeScriptBin "st-audio-get-capture-volume" ''
       #!${pkgs.bash}/bin/bash
       amixer sget Capture | awk -F '[][]' '/.*Left:/ { print $2 }'
    ''
    )

    ( writeScriptBin "st-audio-get-capture-status" ''
       #!${pkgs.bash}/bin/bash
       amixer sget Capture | awk -F '[][]' '/.*Left:/ { print $4 }'
    ''
    )

    ( writeScriptBin "st-kb-get-layout" ''
       #!${pkgs.bash}/bin/bash
       ${pkgs.xorg.setxkbmap}/bin/setxkbmap -query | awk '/^layout:/ { printf "%s", $2 }'
    ''
    )

    ( writeScriptBin "st-gpg-update-startup-tty" ''
       #!${pkgs.bash}/bin/bash
       echo UPDATESTARTUPTTY | gpg-connect-agent
    ''
    )

    ( writeScriptBin "st-kb-german" ''
       #!${pkgs.bash}/bin/bash
       ${pkgs.xorg.setxkbmap}/bin/setxkbmap -layout de
    ''
    )

    ( writeScriptBin "st-kb-english" ''
       #!${pkgs.bash}/bin/bash
       ${pkgs.xorg.setxkbmap}/bin/setxkbmap -layout us
    ''
    )

    ( writeScriptBin "st-kb-neo2" ''
       #!${pkgs.bash}/bin/bash
       ${pkgs.xorg.setxkbmap}/bin/setxkbmap -layout de -variant neo
    ''
    )

    ( writeScriptBin "st-otp" ''
       #!${pkgs.bash}/bin/bash
      set -euo pipefail

      # If the yubikey has been used for GPG/SSH tasks, then yubioath doesn't work,
      # so restart the smartcard daemon
      sudo systemctl restart pcscd

      declare selected_key
      selected_key=$(${pkgs.yubikey-manager}/bin/ykman oath list | ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]' | ${pkgs.gawk}/bin/awk -F ":" '{print $1}' | ${pkgs.dmenu}/bin/dmenu)

      declare selected_key_code
      selected_key_code=$(${pkgs.yubikey-manager}/bin/ykman oath code "''${selected_key}" | ${pkgs.gawk}/bin/awk -F ':' '{ printf "%s", $2 }' | ${pkgs.gawk}/bin/awk '{ printf "%s", $2 }')

      printf "%s" "''${selected_key_code}" | ${pkgs.xdotool}/bin/xdotool type --file -
    ''
    )
  ];

  # So system utility zsh completions are available
  environment.pathsToLink = [ "/share/zsh" ];

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
      # extraOptions = "--ipv6";
    };
  };

  # Yubikey stuff
  services.pcscd.enable = true;

  # It's useful to be able to manage firmware
  services.fwupd.enable = true;

  # And thunderbolt things
  services.hardware.bolt.enable = true;

  # # So that FF/Chrome can use a yubikey for auth
  # hardware.u2f.enable = true;

  programs = {
    ssh.startAgent = false;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Honestly, nano can just go and die in a fire
    vim.defaultEditor = true;

    bash = {
      enableCompletion = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions = {
        enable = true;
      };
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [ "git" ];
      };
      syntaxHighlighting = {
        enable = true;
      };
      # zsh-autoenv = {
      #   enable = true;
      # };
    };

    wireshark = {
      enable = true;
    };
  };

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    openFirewall = false;
  };

  # Allow docker0 to bypass the firewall
  networking.firewall.extraCommands = ''
    ip46tables -I nixos-fw 1 -i docker0 -j nixos-fw-accept
  '';

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";

    displayManager = {
      defaultSession = "none+xmonad";

      lightdm.enable = true;

      # TODO: There has to be a better place for this
      sessionCommands = ''
        ${pkgs.feh}/bin/feh --bg-fill ~/.config/wallpapers/towelday2013-A.jpg
      '';
    };

    windowManager = {
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: with haskellPackages; [
          xmobar
        ];
      };
    };

    desktopManager = {
      xterm.enable = false;
    };
  };

  # Install the keyring fully (home manager can't do this by itself)
  services.gnome = {
    gnome-keyring.enable = true;
  };

  programs.seahorse.enable = true;

  # So the key chain is unlocked on login
  security.pam.services.lightdm.enableGnomeKeyring = true;

  security.sudo.extraRules = lib.mkAfter [
    {
      groups = [ "stears" ];
      commands = [
        {
          command = ''${pkgs.systemd}/bin/systemctl restart pcscd'';
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.compton = {
    enable          = true;
    # fade            = true;
    # inactiveOpacity = "0.9";
    # shadow          = true;
    # fadeDelta       = 4;
  };

  # services.xserver.xkbOptions = "eurosign:e";

  # Enable passwd and co.
  users.mutableUsers = true;

  users.extraGroups.stears = {
    gid = 1000;
  };

  users.extraGroups.colleagues = {};

  users.users.stears = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "wireshark" "video" "vboxusers" "colleagues" ];
    createHome = true;
    home = "/home/stears";
    uid = 1000;
    group = "stears";
    shell = "${pkgs.zsh}/bin/zsh";
    initialPassword = "initial-password";

    openssh.authorizedKeys.keys = [
      (import ./keys/pubkey-philip-yk.nix)
      (import ./keys/pubkey-philip-kp2a.nix)
      (import ./keys/pubkey-philip-old.nix)
      (import ./keys/pubkey-philip-iphone.nix)
    ];
  };

  home-manager.users.stears = import ./stears/hm.nix { inherit pkgs lib; };

  users.users.robashton = {
    isNormalUser = true;
    extraGroups = [];
    createHome = true;
    home = "/home/robashton";
    group = "colleagues";
    hashedPassword = "!";

    openssh.authorizedKeys.keys = [
      (import ./keys/pubkey-dero.nix)
    ];
  };

  users.users.id3as = {
    isNormalUser = true;
    extraGroups = [];
    createHome = true;
    home = "/home/id3as";
    group = "colleagues";
    hashedPassword = "!";

    openssh.authorizedKeys.keys = [
      (import ./keys/pubkey-id3as.nix)
    ];
  };

  systemd.tmpfiles.rules = [
    # Create a directory for files shared with colleagues, set
    # the gid bit so that files get created with the group
    # of the directory, rather than the group of the user
    "q /run/colleagues 2770 stears colleagues 10d"
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
