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
in
{

  home.keyboard.layout = "tr";

  services.grobi = {
    enable = true;
    rules = [
      {
        name = "inno-dell-dock-tr";
        outputs_present = [ "eDP-1" "DP-1-2" ];
        outputs_connected = [ "DP-1-2" ];
        primary = "DP-1-2";
        atomic = true;
        configure_single = "DP-1-2@3840x2160";
        execute_after = get_dpi_commands { dpi=192; };
      }
      {
        name = "inno-dell-dock-office";
        outputs_present = [ "eDP-1" "DP-3-1" "DP-3-2" ];
        outputs_connected = [ "DP-3-1" "DP-3-2" ];
        primary = "DP-3-1";
        atomic = true;
        configure_row = [ "DP-3-2" "DP-3-1" ];
        execute_after = get_dpi_commands { dpi=96; };
      }
      {
        name = "inno-dell-dock";
        outputs_present = [ "eDP-1" "DP-1" "DP-2" "DP-3" "DP-4" "DP-3-1" ];
        outputs_connected = [ "DP-3-2" "DP-3-3" ];
        primary = "DP-3-3";
        atomic = true;
        configure_row = [ "DP-3-2" "DP-3-3" ];
        execute_after = get_dpi_commands { dpi=96; };
      }
      {
        name = "single";
        outputs_connected = [ "eDP-1" ];
        outputs_present = [ "DP-1" "DP-2" "DP-3" "DP-4" "DP-3-1" "DP-3-2" "DP-3-3" ];
        configure_single = "eDP-1@1920x1200";
        primary = "eDP-1";
        atomic = true;
        execute_after = get_dpi_commands { dpi=118; };
      }
      {
        name = "fallback";
        configure_single = "eDP-1@1920x1200";
        primary = "eDP-1";
        atomic = true;
        execute_after = get_dpi_commands { dpi=118; };
      }
    ];
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
    # ${pkgs.dbus}/bin/dbus-run-session ${pkgs.myAwesome}/bin/awesome
    windowManager.command = ''
      ${pkgs.dbus}/bin/dbus-run-session ${pkgs.awesome}/bin/awesome
    '';
  };

  home.pointerCursor = {
    x11.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

}
