# vim: set sts=2 ts=2 sw=2 expandtab :

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Common things
      ./../../common

      # Hardware & user specific things
      ./stears
    ];

  # Use the systemd-boot EFI boot loader - need
  # this because we're doing whole-disk encryption.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices.cryptlvm = {
    device = "/dev/disk/by-label/system";
    allowDiscards = true;
  };

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "stxps";

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  networking.firewall.allowedTCPPorts = [
    22    # SSH
    5060  # SIP
    30080 # Local HTTP
    30443 # Local HTTPS
    30666 # Random things
    3000  # MEE
  ];

  networking.firewall.allowedUDPPorts = [
    79
    5060
    5353 # mDNS
  ];

  networking.firewall.allowedUDPPortRanges = [
    { from = 4000; to = 4100; }
  ];

  networking.dhcpcd.extraConfig =
    ''
      # Disable APIPA addresses
      noipv4ll
    '';

  # Enable UPower (needed for keyboard backlight control)
  services.upower.enable = true;
  systemd.services.upower.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  hardware.pulseaudio = {

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

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

  environment.systemPackages = with pkgs; [

    # Network Manager
    networkmanager_dmenu

    # Backlight Control
    brightnessctl
  ];

  networking.networkmanager.enable = true;

  services.xserver.xkbOptions = "caps:ctrl_modifier";

  # For iDevice access
  services.usbmuxd.enable = true;
}
