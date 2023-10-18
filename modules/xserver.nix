{config, pkgs, ...}:

let
  # baseconfig = { allowUnfree = true; };
  # unstable = import (
    # fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
  # ) { config = baseconfig; };
  get_dpi_commands = list: [
    "${pkgs.xorg.xrandr}/bin/xrandr --dpi ${toString list.dpi}"
    "echo 'Xft.dpi: ${toString list.dpi}' | ${pkgs.xorg.xrdb}/bin/xrdb -merge"
  ];
  fingerprint_xpsinternal = {
    eDP-1 = "00ffffffffffff004d10f81400000000181e0104b51d12780a6e60a95249a1260d50540000000101010101010101010101010101010172e700a0f06045903020360020b41000001828b900a0f06045903020360020b410000018000000fe005648545957804c513133345231000000000002410332011200000b010a202001e002030f00e3058000e606050160602800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa";
  };
  fingerprint_dellWide = {
    DP-1 = "00ffffffffffff0010ac5bd15634373006200104b5502178fbb495ac5046a025175054a54b00714f8140818081c081009500b300d1c0e77c70a0d0a0295030203a001d4e3100001a000000ff00343750584e48330a2020202020000000fc0044454c4c205333343233445743000000fd003064a0a03c010a202020202020011d020326f15001020307111216130446141f05104c5a2309070783010000681a000001013064004dd2707ed0a046500e203a001d4e3100001a507800a0a038354030203a001d4e3100001a7e4800e0a0381f4040403a001d4e3100001a9d6770a0d0a0225030203a001d4e3100001a000000000000000000000000000000000084";
  };
  fingerprint_dell4k = {
    DP-1 = "00ffffffffffff0010ac05d1565738300d1f010380462878ea3c55ad4f46a827115054a54b00a9c0b300d100714fa9408180d1c0010131ce0046f0705a8020108a00b9882100001a000000ff00384830525442330a2020202020000000fc0044454c4c20533332323151530a000000fd00283c1d8c3c000a202020202020012e020340f15461050403020716010611121513141f105d5e5f6023090707830100006d030c001000383c20006001020367d85dc401788000681a00000100283ce6565e00a0a0a0295030203500b9882100001a023a801871382d40582c4500b9882100001ea8ac00a0f070338030303500b9882100001a00000000000000000018";
  };
in
{

  home.keyboard.layout = "tr";

  programs.autorandr= {
    enable = true;
    hooks = {
      predetect = {};

      preswitch = {};

      postswitch = {
        "change-dpi" = ''
          case "$AUTORANDR_CURRENT_PROFILE" in
            single)
              DPI=118
              ;;
            wide)
              DPI=112
              ;;
            trsetup)
              DPI=140
              ;;
            *)
              exit 1
          esac

          echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
        '';
      };
    };

    profiles = {
      "single" = {
        fingerprint = fingerprint_xpsinternal;

        config = {
          eDP-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1200";
            rate = "60.04";
            rotate = "normal";
          };
        };
      };

      "wide" = {
        fingerprint = fingerprint_dellWide // fingerprint_xpsinternal;

        config = {
          DP-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "3440x1440";
            rate = "100.00";
          };
          eDP-1 = {
            enable = false;
          };
        };
      };

      "trsetup" = {
        fingerprint = fingerprint_dell4k // fingerprint_xpsinternal;

        config = {
          DP-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "3840x2160";
            rate = "60.00";
          };
          eDP-1 = {
            enable = false;
          };
        };
      };
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 10;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
      gtk-button-images = 1;
      gtk-icon-theme-name = "Papirus";
      gtk-menu-images = 1;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
  };

  qt = {
    enable = true;
    style.name = "Fusion";
  };

  xsession = {
    enable = true;
    numlock.enable = true;

    scriptPath = ".hm-xsession";
    # ${pkgs.dbus}/bin/dbus-run-session ${pkgs.awesome}/bin/awesome
    windowManager.command = ''
    ${pkgs.dbus}/bin/dbus-run-session ${pkgs.myAwesome}/bin/awesome
    '';
  };

  home.pointerCursor = {
    x11.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

}
