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

  boot.initrd.luks.devices = [
    {
      name = "cryptlvm";
      device = "/dev/disk/by-label/system";
      # preLVM = true;
      allowDiscards = true;
    }
  ];

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "sthades";

  # Name interfaces
  services.udev.extraRules =
    ''
      KERNEL=="eth*", ATTR{address}=="54:b2:03:04:7d:68", NAME="trusted"
      KERNEL=="eth*", ATTR{address}=="54:b2:03:04:7d:67", NAME="unused"
    '';

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  networking.firewall.interfaces.trusted = {
    allowedTCPPorts = [
      22    # SSH
      5060  # SIP
      30080 # Local HTTP
      30443 # Local HTTPS
    ];

    allowedUDPPorts = [
      5060  # SIP
      5353  # mDNS
    ];

    allowedUDPPortRanges = [
      { from = 4000; to = 4100; } # RTP
    ];
  };

  networking.firewall.extraCommands = ''

    # Allow the router to access services over the DMZ interface
    iptables -I nixos-fw 1 -i dmz -s 82.68.28.6 -p tcp -m tcp --dport 22 -j nixos-fw-accept

    # Restricted access to SIP
    iptables -I nixos-fw 1 -i dmz -s 213.95.30.153 -p udp -m udp --dport 5060 -j nixos-fw-accept
    iptables -I nixos-fw 1 -i dmz -s 213.95.30.153 -p tcp -m tcp --dport 5060 -j nixos-fw-accept
    iptables -I nixos-fw 1 -i dmz -s 213.95.30.153 -p tcp -m tcp --dport 5061 -j nixos-fw-accept
    iptables -I nixos-fw 1 -i dmz -s 213.95.30.153 -p udp -m udp --dport 4000:4100 -j nixos-fw-accept
    iptables -I nixos-fw 1 -i dmz -s 213.95.30.103 -p udp -m udp --dport 4000:4100 -j nixos-fw-accept
  '';

  networking.vlans = {
    dmz =   { id = 16; interface = "trusted"; };
  };

  networking.dhcpcd.extraConfig =
    ''
      interface trusted
      metric 100

      interface dmz
      metric 50
    '';

  # VAAPI
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl

      # Rob's fix
      (pkgs.intel-media-driver.overrideAttrs (oldAttrs: {
        name = "intel-media-driver";
        postFixup = ''
          patchelf --set-rpath "$(patchelf --print-rpath $out/lib/dri/iHD_drv_video.so):${stdenv.lib.makeLibraryPath [ xorg.libX11  ]}" \
            $out/lib/dri/iHD_drv_video.so
        '';
      }))
    ];
  };

  services.xserver.xkbOptions = "altwin:swap_alt_win";
}
