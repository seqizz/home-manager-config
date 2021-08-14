{config, pkgs, ...}:

let
  # baseconfig = { allowUnfree = true; };
  # unstable = import (
    # fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
  # ) { config = baseconfig; };
in
{

  home.keyboard.layout = "tr";

  services.grobi = {
    enable = true;
    rules = [
      {
        name = "inno-dell-dock";
        outputs_present = [ "eDP-1" "DP-1" "DP-2" "DP-3" "DP-4" "DP-3-1" ];
        outputs_connected = [ "DP-3-2" "DP-3-3" ];
        primary = "DP-3-3";
        atomic = true;
        configure_row = [ "DP-3-2" "DP-3-3" ];
        execute_after = [
          "${pkgs.xorg.xrandr}/bin/xrandr --dpi 96"
        ];
      }
      {
        name = "single-on-dock";
        outputs_connected = [ "eDP-1" ];
        outputs_present = [ "DP-1" "DP-2" "DP-3" "DP-4" "DP-3-1" "DP-3-2" "DP-3-3" ];
        configure_single = "eDP-1@1920x1200";
        primary = true;
        atomic = true;
        execute_after = [
          "${pkgs.xorg.xrandr}/bin/xrandr --dpi 112"
        ];
      }
      {
        name = "mobile";
        outputs_connected = [ "eDP-1" ];
        outputs_present = [ "DP-1" "DP-2" "DP-3" "DP-4" ];
        configure_single = "eDP-1@1920x1200";
        primary = true;
        atomic = true;
        execute_after = [
          "${pkgs.xorg.xrandr}/bin/xrandr --dpi 112"
        ];
      }
      {
        name = "fallback";
        configure_single = "eDP-1@1920x1200";
        primary = true;
        atomic = true;
        execute_after = [
          "${pkgs.xorg.xrandr}/bin/xrandr --dpi 112"
        ];
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

    pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 32;
    };

    scriptPath = ".hm-xsession";
    windowManager.command = ''
      ${pkgs.dbus}/bin/dbus-run-session ${pkgs.awesome}/bin/awesome
      # ${pkgs.dbus}/bin/dbus-run-session ${pkgs.myAwesome}/bin/awesome
    '';
  };
}
