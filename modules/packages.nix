{ config, pkgs, ...}:

let
  baseconfig = { allowUnfree = true; };
# In case I want to use the packages I need on other channels
  unstable_small = import (
    fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable-small.tar.gz
  ) { config = baseconfig; };
  unstable = import (
    fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
  ) { config = baseconfig; };
  bleeding = import (
    fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz
  ) { config = baseconfig; };
  # For overrides
  nixpkgs = import <nixpkgs> {};
  sysconfig = (import <nixpkgs/nixos> {}).config;
  my_scripts = (import ./scripts.nix {pkgs = pkgs;});
in

{
  # For overrides
  # XXX: move to overlays-compat?
  nixpkgs.config = {
    enable = true;
    allowUnfree = true;

    packageOverrides = pkgs: rec {
      adminapi = unstable.python38Packages.callPackage /devel/ig/nix-definitions/packages/adminapi.nix {};
      pyvis = unstable.python38Packages.callPackage ~/.config/nixpkgs/modules/packages/pyvis.nix {};
      wezterm = pkgs.callPackage ~/.config/nixpkgs/modules/packages/wezterm.nix {};
      paoutput = pkgs.callPackage ~/.config/nixpkgs/modules/packages/paoutput.nix {};
      # @Reference patching apps
      # krunner-pass = pkgs.krunner-pass.overrideAttrs (attrs: {
        # patches = attrs.patches ++ [ ~/syncfolder/dotfiles/nixos/home/gurkan/.config/nixpkgs/modules/packages/pass-dbus.patch ];
      # });
      # weechat = (pkgs.weechat.override {
        # configure = { availablePlugins, ... }: {
          # plugins = with availablePlugins; [
            # (python.withPackages (ps: with ps; [
              # websocket_client
              # dbus-python
              # notify
            # ]))
          # ];
        # };
      # });
    };
    # @Reference this is sometimes needed
    # allowBroken = true;
  };

  home.packages = with pkgs;
    # Conditionals first
    (if sysconfig.networking.hostName == "innixos" || sysconfig.networking.hostName == "innodellix" then [
      slack
      unstable.teams
      gnome3.gnome-keyring # needed for teams
      discord
      zoom-us
      my_scripts.innovpn-toggle
      thunderbird
    ] else [] ) ++ [

    # Now overrides

    ( gimp-with-plugins.override { plugins = with gimpPlugins; [ gmic ]; })
    ( pass.withExtensions ( ps: with ps; [ pass-genphrase ]))
    ( unstable.python38.withPackages ( ps: with ps; [
        adminapi
        black
        coverage
        flake8
        ipython
        libtmux
        libvirt
        netaddr
        pep8
        pip
        pylint
        pynvim
        pysnooper
        pyvis
        pyyaml
        requests
        setuptools
        vimwiki-markdown
        virtualenv
        xlib
    ]))

    # non-stable stuff, subject to change
    unstable.steam
    # unstable.update-nix-fetchgit

    # Rest is sorted
    adbfs-rootless
    alacritty
    alttab
    arandr # I might need manual xrandr one day
    arc-kde-theme # for theming kde apps
    arc-theme
    ark # compressed file manager
    blueman # if shits itself, try bluedevil
    brightnessctl
    calibre # e-book manager written by a jerk
    chromium
    clipcat
    ffmpeg
    ffmpegthumbs
    firefox
    geany
    gitstatus
    glxinfo
    gnome3.dconf # some apps keep its config in this shit: shotwell
    graphviz # some weird tools *sometimes* need this
    grobi # no more autorandr
    imagemagick
    inotify-tools
    jmtpfs # mount MTP devices easily
    # kde-cli-tools # required to open kde-gtk-config
    # kde-gtk-config # best GTK theme selector
    libnotify
    libreoffice
    lxqt.lximage-qt
    maim
    meld # diff tool
    mpv
    my_scripts.git-cleanmerged
    my_scripts.psitool-script
    my_scripts.tarsnap-dotfiles
    my_scripts.xinput-toggle
    my_scripts.workman-toggle
    pamixer # pulseaudio mixer
    papirus-icon-theme
    paoutput
    pavucontrol
    pcmanfm-qt # A file-manager which fucking works
    # pdftk # split-combine pdfs
    picom # X compositor which sucks, also do not use services.picom
    playerctl
    # poppler_utils # for pdfunite
    proxychains
    puppet-lint
    qpdfview
    # qt5ct # QT5 theme selector
    simplescreenrecorder
    slock
    spotify
    steam-run # helper tool for running shitty binaries
    tarsnap
    taskwarrior
    tdesktop # telegram
    tightvnc
    wally-cli
    wezterm
    xautomation
    xclip
    xdotool
    xlibs.xmodmap
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    xorg.xwininfo
    xournal # annotate pdfs
    xsel
  ];
}
