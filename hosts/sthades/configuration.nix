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
      KERNEL=="eth*", ATTR{address}=="00:30:93:10:19:ad", NAME="lab"
    '';

  # Open ports in the firewall.
  networking.firewall.allowPing = true;

  networking.firewall.trustedInterfaces = [
    "lab"
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

    # Allow the router to access services over the DMZ interface
    iptables -I nixos-fw 1 -i dmz -s 82.68.28.6 -p tcp -m tcp --dport 22 -j nixos-fw-accept

    # # Restricted access to SIP
    # iptables -I nixos-fw 1 -i dmz -s 213.95.30.38 -p udp -m udp --dport 5060 -j nixos-fw-accept
    # iptables -I nixos-fw 1 -i dmz -s 213.95.30.38 -p tcp -m tcp --dport 5060 -j nixos-fw-accept
    # iptables -I nixos-fw 1 -i dmz -s 213.95.30.38 -p tcp -m tcp --dport 5061 -j nixos-fw-accept
    # iptables -I nixos-fw 1 -i dmz -s 213.95.30.38 -p udp -m udp --dport 4000:4100 -j nixos-fw-accept

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
    lab = {
      ipv4 = {
        addresses = [
          { address = "10.24.16.1"; prefixLength = 16; }
          { address = "10.24.16.2"; prefixLength = 16; }
          { address = "10.24.16.3"; prefixLength = 16; }
          { address = "10.24.16.4"; prefixLength = 16; }

          { address = "10.24.16.5"; prefixLength = 16; }
          { address = "10.24.16.6"; prefixLength = 16; }
          { address = "10.24.16.7"; prefixLength = 16; }
          { address = "10.24.16.8"; prefixLength = 16; }

          { address = "10.24.16.9"; prefixLength = 16; }
          { address = "10.24.16.10"; prefixLength = 16; }
          { address = "10.24.16.11"; prefixLength = 16; }
          { address = "10.24.16.12"; prefixLength = 16; }

          { address = "10.24.16.13"; prefixLength = 16; }
          { address = "10.24.16.14"; prefixLength = 16; }
          { address = "10.24.16.15"; prefixLength = 16; }
          { address = "10.24.16.16"; prefixLength = 16; }
        ];
      };
    };

    dmz = {
      ipv4 = {
        addresses = [
          { address = "82.68.28.3"; prefixLength = 29; }
          { address = "82.68.28.4"; prefixLength = 29; }
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
      "d3.philipstears.com" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://82.68.28.3:3080/";
            proxyWebsockets = true;
            extraConfig = ''
              allow 82.68.28.0/29;
              deny all;
            '';
          };
        };
      };

      "d4.philipstears.com" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://82.68.28.4:3080/";
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

  security.acme.certs = {
    "d3.philipstears.com".email = "philip@philipstears.com";
    "d4.philipstears.com".email = "philip@philipstears.com";
  };

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

    # Let 32-bit application use OpenGL
    driSupport32Bit = true;
  };

  # I'm using an Apple keyboard, make it sane
  services.xserver.xkbOptions = "altwin:swap_alt_win,caps:ctrl_modifier";

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
      # vkd3dSupport = true;
    })

    # Useful for QT things
    hicolor-icon-theme
  ];
}
