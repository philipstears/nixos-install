# vim: set sts=2 ts=2 sw=2 expandtab :

# TODO:
# - Use actkbd for system level hotkeys as per //nixos.wiki/wiki/Backlight
# - Use config.xdg.configHome for $HOME/.config/

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "dd94a849df69fe62fe2cb23a74c2b9330f1189ed";
    ref = "release-18.09";
  };

  private = import ./private { inherit pkgs; };
in
{
  imports =
    [ # home-manager for per-user management
      "${home-manager}/nixos"
    ];

  networking.extraHosts = private.configuration.hosts;

  # Select internationalisation properties.
  i18n = {
    # consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";

    # English Language with sensible formatting
    defaultLocale = "en_DK.UTF-8";
  };

  # Set your time zone.
  services.timesyncd.enable = true; # the default, but explicitness is a good thing
  time.timeZone = "Europe/Vienna";

  # Allow non-free things like firefox-bin
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # Admin & Development Tools
    wget
    vim
    pavucontrol
    openssh
    git git-lfs
    tmux
    ripgrep
    htop iotop iftop
    lftp
    tree
    bashCompletion
    wireshark
    wireshark-cli
    jq
    awscli
    unzip

    # Docker - until I can obviate it
    docker
    docker-gc
    docker-ls

    # Terraform - this should really be in project shells I think
    terraform
    terraform-providers.aws
    terraform-landscape

    # General web things
    firefox-bin
    google-chrome
    skypeforlinux
    slack

    # Security
    gnupg
    srm
    keepassxc

    # Desktop Env
    gnome3.dconf # for the few gnome things I use, such as seahorse
    gnome3.dconf-editor
    gnome3.gnome-screenshot
    mate.mate-calc
    dmenu
    networkmanager_dmenu
    xclip
    alacritty
    feh
    libreoffice-still

    # Desktop Env Support Utilities
    ( writeScriptBin "otp" (builtins.readFile ./files/scripts/otp) )

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
       setxkbmap -query | awk '/^layout:/ { printf "%s", $2 }'
    ''
    )

    ( writeScriptBin "st-gpg-update-startup-tty" ''
       #!${pkgs.bash}/bin/bash
       echo UPDATESTARTUPTTY | gpg-connect-agent
    ''
    )
  ];

  # So system utility zsh completions are available
  environment.pathsToLink = [ "/share/zsh" ];

  virtualisation = {
    docker.enable = true;
  };

  # Yubikey stuff
  services.pcscd.enable = true;

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
    challengeResponseAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  networking.firewall.allowedTCPPorts = [
    22 5060 30080 30443
  ];

  networking.firewall.allowedUDPPorts = [
    79 5060
  ];

  networking.firewall.allowedUDPPortRanges = [
    { from = 4000; to = 4100; }
  ];

  networking.networkmanager.enable = true;

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
      lightdm.enable = true;

      # TODO: There has to be a better place for this
      sessionCommands = ''
        ${pkgs.feh}/bin/feh --bg-fill ~/.config/wallpapers/towelday2013-A.jpg
      '';
    };

    windowManager = {
      default = "xmonad";

      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: with haskellPackages; [
          xmobar
        ];
      };
    };

    desktopManager = {
      default = "none";
      xterm.enable = false;
    };
  };

  services.gnome3 = {

    # Install the keyring fully (home manager can't do this by itself)
    gnome-keyring.enable = true;

    # So we can inspect the key chain
    seahorse.enable = true;
  };

  # So the key chain is unlocked on login
  security.pam.services.lightdm.enableGnomeKeyring = true;

  services.compton = {
    enable          = true;
    # fade            = true;
    # inactiveOpacity = "0.9";
    # shadow          = true;
    # fadeDelta       = 4;
  };

  # services.xserver.xkbOptions = "eurosign:e";

  # Enable UPower (needed for keyboard backlight control)
  services.upower.enable = true;
  systemd.services.upower.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # VAAPI
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Enable passwd and co.
  users.mutableUsers = true;

  # Don't forget to set a password with ‘passwd’.
  users.extraGroups.stears = {
    gid = 1000;
  };

  users.users.stears = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "wireshark" ];
    createHome = true;
    home = "/home/stears";
    uid = 1000;
    group = "stears";
    shell = "${pkgs.zsh}/bin/zsh";

    openssh.authorizedKeys.keys = [
      (import ./files/philip-pubkey.nix)
    ];
  };

  home-manager.users.stears = {
    home.packages = with pkgs; [
      ktouch
      spotify
      imagemagick
      electrum

      ffmpeg-full
      vlc
      sox
      audacity
      linphone
      ekiga

      powerline-fonts

      # It's useful to be able to control my backlight
      xorg.xbacklight

      # The best "pure" locker that I've
      # found so far
      i3lock

      # TODO: I don't think I need this explicitly,
      # home-manager's screen-locker uses it
      # internally
      xss-lock

      # xdg-screensaver looks for certain DEs or,
      # falls back to looking for things like
      # xscreensaver (which I don't have), or
      # xautolock, which I do use via
      # home-manager's screen-locker, so make
      # it available to the shell for
      # xdg-screensaver to find
      xautolock

      # My stuff
      private.packages.jump
      private.packages.project
    ];

    # So Skype doesn't log out on each restart -
    # this starts the gnome-keyring as a user
    # service
    services.gnome-keyring = {
      enable = true;
      components = [ "secrets" ];
    };

    programs.git = {
      enable = true;
      userName  = "philipstears";
      userEmail = "philip@philipstears.com";
    };

    programs.vim = {
      enable = true;
      plugins = [
        "vim-airline"
        "nerdtree"
        "ctrlp"
        "editorconfig-vim"
        "vim-surround"
        "vim-fugitive"
        "youcompleteme"
        "typescript-vim"
      ];
      settings = { ignorecase = true; };
      extraConfig = (builtins.readFile ./files/vimrc);
    };

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

    home.file.".emacs.d/init.el".source = ./files/emacs/init.el;

    # Per-user ZSH stuff, builds on the global bits
    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      history = {
        share = false;
      };
      shellAliases = {
      };
      sessionVariables = {
      };
      initExtra = ''
        # Update history incrementally
        INC_APPEND_HISTORY="true"

        DISABLE_AUTO_TITLE="true"

        # Colors please
        eval "$(dircolors -b)"

        # Hide default user prompt
        DEFAULT_USER=''${USER}

        # Let Java know that we're using a non-reparenting WM
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      profileExtra = ''
      '';
      plugins = [];
    };

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    programs.home-manager = {
      enable = true;
    };

    # TODO: Does this achieve anything?
    services.screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -i ~/.config/lockscreen/towelday2013-A.png";
    };

    home.file.".xmobarrc".source = ./files/xmobarrc;

    home.file.".config/wallpapers" = {
      source = ./files/wallpapers;
      recursive = true;
    };

    home.file.".config/lockscreen" = {
      source = ./files/lockscreen;
      recursive = true;
    };

    home.file.".config/alacritty/alacritty.yml".source = ./files/alacritty.yml;

    programs.tmux = {
      enable = true;
      extraConfig = ''
        set -sg escape-time 0
        set -g history-limit 16384

        # Enable true-color for terminal type under which tmux runs
        set -ga terminal-overrides ",screen-256color:Tc"

        # The terminal type to surface inside of tmux
        set -g default-terminal "screen-256color"
      '';
      };

    # xsession.initExtra = ''
    #   ${pkgs.feh}/bin/feh --bg-fill ~/.config/wallpapers/towelday2013-A.jpg
    # '';

    # Need this for xsession.initExtra to work, which is used by home-manager's
    # screen-locker to run xss-lock in the background to set X's screen-saver
    xsession.enable = true;

    xsession.windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = pkgs.writeText "xmonad.hs" ''
          import XMonad
          import XMonad.Layout.NoBorders

          import XMonad.Hooks.DynamicLog

          import XMonad.Util.EZConfig(additionalKeys)
          import Graphics.X11.ExtraTypes.XF86

          main = do
            updatedConfig <-
              statusBar xmobarPath myPP toggleStrutsKey myConfig

            xmonad updatedConfig

          myPP =
            def
            { ppCurrent = xmobarColor "yellow" "" . wrap "[" "]"
            , ppTitle   = const ""
            , ppLayout  = const ""
            , ppVisible = wrap "(" ")"
            , ppUrgent  = xmobarColor "red" "yellow"
            , ppSep     = " | "
            }

          myConfig =
            let
              originalConfig =
                def
            in
              originalConfig
                { terminal = alacrittyPath
                , layoutHook = noBorders $ layoutHook originalConfig
                }
                `additionalKeys`
                [ ((0                         , xF86XK_AudioRaiseVolume), spawn "amixer -q set Master 5%+")
                , ((0                         , xF86XK_AudioLowerVolume), spawn "amixer -q set Master 5%-")
                , ((0                         , xF86XK_AudioMute),        spawn "amixer -q set Master toggle")
                , ((shiftMask                 , xF86XK_AudioRaiseVolume), spawn "amixer -q set Capture 5%+")
                , ((shiftMask                 , xF86XK_AudioLowerVolume), spawn "amixer -q set Capture 5%-")
                , ((shiftMask                 , xF86XK_AudioMute),        spawn "amixer -q set Capture toggle")

                , (((modMask originalConfig)  , xK_l),                    spawn "xdg-screensaver lock")
                , (((modMask originalConfig)  , xK_o),                    spawn "otp")
                , (((modMask originalConfig)  , xK_s),                    spawn "gnome-screenshot -i")
                , (((modMask originalConfig)  , xK_c),                    spawn "mate-calc")
                , (((modMask originalConfig)  , xK_n),                    spawn "networkmanager_dmenu")
                ]

          toggleStrutsKey XConfig {XMonad.modMask = modMask} =
            (modMask, xK_b)

          xmobarPath = "${pkgs.haskellPackages.xmobar}/bin/xmobar"

          alacrittyPath = "${pkgs.alacritty}/bin/alacritty"
      '';
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
