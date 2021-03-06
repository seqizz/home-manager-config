{config, pkgs, ...}:
let
  baseconfig = { allowUnfree = true; };
  # In case I want to use the packages I need on other channels
  unstable = import (
    fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
  ) { config = baseconfig; };
  lock-helper = (import ./scripts.nix {pkgs = pkgs;}).lock-helper;
  auto-rotate = (import ./scripts.nix {pkgs = pkgs;}).auto-rotate;
  secrets = import ./secrets.nix {pkgs=pkgs;};
in
{
  # TODO: check later, https://rycee.gitlab.io/home-manager/options.html#opt-systemd.user.startServices
  # systemd.user.startServices = "sd-switch";

  services = {
    kdeconnect.enable = true;
    playerctld.enable = true;
    udiskie.enable = true;
    network-manager-applet.enable = true;

    redshift = {
      enable = true;
      latitude = "53.551086";
      longitude = "9.993682";
    };

    unclutter = {
      enable = true;
      threshold = 15;
      timeout = 2;
      extraOptions = [ "ignore-scrolling" ];
    };

    # XXX
    # /bin/sh: line 1: env: command not found
    # Fuk me if I understand, reverting for now
    # https://github.com/nix-community/home-manager/issues/3095
    # gpg-agent = {
      # enable = true;
      # defaultCacheTtl = 86400;
      # maxCacheTtl = 86400;
      # pinentryFlavor = null;
      # extraConfig = ''
        # pinentry-program ${pkgs.pinentry-rofi}/bin/pinentry-rofi
        # auto-expand-secmem
      # '';
    # };

    # XXX: Not yet on 21.05 channel
    # xidlehook = {
      # enable = true;
      # not-when-fullscreen = true;
      # timers = [
        # {
          # # delay = 250;
          # delay = 30;
          # command = "${lock-helper}/bin/lock-helper start";
          # canceller = "${lock-helper}/bin/lock-helper cancel";
        # }
        # {
          # # delay = 120;
          # delay = 10;
          # command = "${lock-helper}/bin/lock-helper lock";
          # canceller = "${lock-helper}/bin/lock-helper cancel";
        # }
      # ];
    # };
  };

  systemd.user = {
    startServices = true;
    services = {
      baglan = {
        Unit = {
          Description = "My precious proxy";
        };
        Install = {
          WantedBy = [
            "multi-user.target"
            "graphical-session.target"
          ];
        };
        Service = {
          ExecStart = secrets.proxyCommand;
          RestartSec = 10;
          Restart = "always";
        };
      };

      xidlehook = {
        Unit = {
          Description = "My screen locker";
          After = [
            "graphical-session.target"
          ];
        };
        Install = {
          WantedBy = [
            "multi-user.target"
            "graphical-session.target"
          ];
        };
        Service = {
          ExecStart = ''
            ${unstable.xidlehook}/bin/xidlehook --not-when-fullscreen --timer 250 '${lock-helper}/bin/lock-helper start' '${lock-helper}/bin/lock-helper cancel' --timer 120 '${lock-helper}/bin/lock-helper lock' '${lock-helper}/bin/lock-helper cancel'
          '';
          RestartSec = 25;
          Restart = "always";
          Environment = "DISPLAY=:0";
          PrivateTmp = "false";
        };
      };

      auto-rotate = {
        Unit = {
          Description = "Automatic screen rotation helper";
          After = [
            "graphical-session.target"
          ];
        };
        Service = {
          ExecStart = "${pkgs.bash}/bin/bash ${auto-rotate}/bin/auto-rotate";
          ExecStop = "${pkgs.psmisc}/bin/killall monitor-sensor";
          RestartSec = 5;
          Restart = "always";
          Environment = "DISPLAY=:0";
          PrivateTmp = "false";
        };
      };
    };
  };
}
#  vim: set ts=2 sw=2 tw=0 et :
