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

  # Max jobs to build in parallel
  nix.maxJobs = 4;

  # Needed for nvidia drivers
  nixpkgs.config.allowUnfree = true;

  # Boot options
  boot = {
    loader = {

      # Using grub on darwin because it seems to work better with
      # Windows dual boot
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        devices = [ "nodev" ];
      };

      efi = {
        canTouchEfiVariables = true;
      };
    };

    kernelParams = ["acpi_enforce_resources=lax"];
    kernelModules = [ "nct6775" ];
  };

  networking.hostName = "stdarwin";

  # Windows needs a reg tweak to support UTC in the hardware
  # clock, rather than mess with that, just make NixOS use
  # local time instead :(
  time.hardwareClockInLocalTime = true;

  fileSystems."/video" =
  { device = "/dev/disk/by-label/Video";
    fsType = "exfat";
  };

  fileSystems."/scratch" =
  { device = "/dev/disk/by-label/Scratch";
    fsType = "exfat";
  };

  fileSystems."/transfer" =
  { device = "/dev/disk/by-label/TRANSFER";
    fsType = "vfat";
  };

  fileSystems."/windows" =
  { device = "/dev/disk/by-label/System";
    fsType = "ntfs";
  };

  # Name interfaces
  # NOTE: this changed in 21.05 -
  # https://nixos.org/manual/nixos/stable/index.html#sec-custom-ifnames for details
  services.udev.initrdRules =
    ''
      KERNEL=="eth*", ATTR{address}=="a8:5e:45:ce:7c:b0", NAME="onboard"
      KERNEL=="eth*", ATTR{address}=="a0:36:9f:21:7e:90", NAME="trusted"
    '';

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  networking.firewall.trustedInterfaces = [
    "trusted"
  ];

  networking.firewall.interfaces.trusted = {
    allowedTCPPorts = [
      22    # SSH
      5060  # SIP
      3080  # Local HTTP
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

  networking.firewall.allowedTCPPorts = [
    443 # NGINX (restrictions are handled by NGINX itself)
    80  # NGINX (restrictions are handled by NGINX itself)
  ];

  networking.firewall.extraCommands = ''

    # Allow anyone access to SIP (for temporary testing)
    iptables -I nixos-fw 1 -i dmz -p udp -m udp --dport 5060 -j nixos-fw-accept
    iptables -I nixos-fw 1 -i dmz -p tcp -m tcp --dport 5060 -j nixos-fw-accept
    iptables -I nixos-fw 1 -i dmz -p tcp -m tcp --dport 5061 -j nixos-fw-accept
    iptables -I nixos-fw 1 -i dmz -p udp -m udp --dport 4000:4100 -j nixos-fw-accept
  '';

  networking.vlans = {
    dmz =   { id = 16; interface = "trusted"; };
  };

  networking.interfaces = {
    dmz = {
      ipv4 = {
        addresses = [
          { address = "82.68.28.2"; prefixLength = 29; }
          { address = "82.68.28.1"; prefixLength = 29; }
        ];
      };
    };
  };

  networking.defaultGateway = {
    address = "82.68.28.5";
    interface = "dmz";
    metric = 10;
  };

  networking.nameservers = [];

  networking.dhcpcd.extraConfig =
    ''
      # Disable DHCP on the DMZ
      denyinterfaces dmz

      # Disable APIPA addresses
      noipv4ll

      # Make sure the trusted LAN
      # has a lower priority than
      # than the DMZ
      interface trusted
      metric 100
    '';

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    commonHttpConfig = ''
    '';

    virtualHosts = {
      "d2.philipstears.com" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://82.68.28.2:3080/";
            proxyWebsockets = true;
            extraConfig = ''
              allow 82.68.28.0/29;
              deny all;
            '';
          };
        };
      };

      "d1.philipstears.com" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://82.68.28.1:3080/";
            proxyWebsockets = true;
            extraConfig = ''
              allow 82.68.28.0/29;
              deny all;
            '';
          };
        };
      };
    };
  };

  security.acme.acceptTerms = true;

  security.acme.certs = {
    "d2.philipstears.com".email = "philip@philipstears.com";
    "d1.philipstears.com".email = "philip@philipstears.com";
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  hardware.pulseaudio = {

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;

    # For steam things
    support32Bit = true;
  };

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    enable = true;

    # Let 32-bit application use OpenGL
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  services.xserver = {

    # Use the proprietary nvidia driver
    videoDrivers = [ "nvidia" ];

    # Force DPI
    dpi = 96;

    # I'm using an Apple keyboard, make it sane
    xkbOptions = "altwin:swap_alt_win,caps:ctrl_modifier";
  };


  virtualisation = {
    virtualbox = {
      host = {
        enable = true;

        # NOTE: This means that virtualbox needs compiling from source, which
        # burns some CPU for a while
        enableExtensionPack = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [

    # Vulkan!
    vulkan-loader
    vulkan-tools

    # Wine with support for both 32-bit and 64-bit applications
    (wineWowPackages.staging.override {
      vulkanSupport = true;
      vkd3dSupport = true;
    })

    # Games
    steam
    steam-run
    playonlinux

    # Useful for QT things
    hicolor-icon-theme
  ];
}
