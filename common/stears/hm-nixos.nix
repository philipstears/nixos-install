# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, lib, ... }:

let
  private = import ../private { inherit pkgs; };
in
{
  programs.home-manager = {
    enable = true;
  };

  home.packages = (with pkgs; [
    ktouch
    spotify
    playerctl
    imagemagick
    electrum
    gimp

    khal

    mediainfo
    vlc
    sox
    audacity
    # linphone
    # ekiga

    # IRC
    weechat

    gitAndTools.tig

    powerline-fonts

    # It's useful to be able to control my backlight
    acpilight

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

    # So we get access to udiskie-mount
    udiskie

    # Typing
    klavaro
    espeak
  ]);

  # So Skype doesn't log out on each restart -
  # this starts the gnome-keyring as a user
  # service
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # Need bash enabled so that direnv can add its
  # config
  programs.bash = {
    enable = true;
  };

  # TODO: Does this achieve anything?
  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -i ${./files/lockscreen/towelday2013-A.png}";
  };

  home.file.".config/wallpapers" = {
    source = ./files/wallpapers;
    recursive = true;
  };

  home.file.".config/alacritty/alacritty.yml".source = ./files/alacritty.yml;

  services.udiskie = {
    enable = true;
  };
}


