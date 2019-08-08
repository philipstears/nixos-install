# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

let
  private = import ../private { inherit pkgs; };
in
{
  imports = [
    ./emacs.nix
  ];

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
      playerctl
      imagemagick
      electrum
      gimp

      khal

      mediainfo
      ffmpeg-full
      vlc
      sox
      audacity
      linphone
      ekiga

      gitAndTools.tig
      tmuxPlugins.resurrect
      tmuxPlugins.sessionist

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

      # So we get access to udiskie-mount
      udiskie
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
      signing = {
        signByDefault = true;
        key = "FA836504B26D139A";
      };
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

    # Need bash enabled so that direnv can add its
    # config
    programs.bash = {
      enable = true;
    };

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
        set -ga terminal-overrides ",xterm-256color:Tc"

        # The terminal type to surface inside of tmux
        set -g default-terminal "xterm-256color"
      '';
      };

    services.udiskie = {
      enable = true;
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
                , ((0                         , xF86XK_AudioNext),        spawn "${pkgs.playerctl}/bin/playerctl next")
                , ((0                         , xF86XK_AudioPrev),        spawn "${pkgs.playerctl}/bin/playerctl previous")
                , ((0                         , xF86XK_AudioPlay),        spawn "${pkgs.playerctl}/bin/playerctl play-pause")
                , ((0                         , xF86XK_AudioStop),        spawn "${pkgs.playerctl}/bin/playerctl stop")

                , (((modMask originalConfig)  , xK_l),                    spawn "xdg-screensaver lock")
                , (((modMask originalConfig)  , xK_o),                    spawn "otp")
                , (((modMask originalConfig)  , xK_s),                    spawn "gnome-screenshot -i")
                , (((modMask originalConfig)  , xK_c),                    spawn "mate-calc")
                , (((modMask originalConfig)  , xK_n),                    spawn "networkmanager_dmenu")

                , (((modMask originalConfig)  , xK_e),                    spawn "st-kb-english")
                , (((modMask originalConfig)  , xK_d),                    spawn "st-kb-german")
                ]

          toggleStrutsKey XConfig {XMonad.modMask = modMask} =
            (modMask, xK_b)

          xmobarPath = "${pkgs.haskellPackages.xmobar}/bin/xmobar"

          alacrittyPath = "${pkgs.alacritty}/bin/alacritty"
      '';
    };
  };

}
