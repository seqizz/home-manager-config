{ config, pkgs, ...}:

let
  baseconfig = { allowUnfree = true; };
# In case I want to use the packages I need on other channels
  unstable = import (
    fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
  ) { config = baseconfig; };
  # bleeding = import (
  #   fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz
  # ) { config = baseconfig; };
  oldversion = import (
    fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz
  ) { config = baseconfig; };
  # For overrides
  nixpkgs = import <nixpkgs> {};
  sysconfig = (import <nixpkgs/nixos> {}).config;
  my_scripts = (import ./scripts.nix {pkgs = pkgs;});
in

{
  nixpkgs = {
    config = {
      enable = true;
      allowUnfree = true;
      # Quick-overrides
      packageOverrides = pkgs: rec {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
        adminapi = pkgs.python3Packages.callPackage /devel/ig/nix-definitions/packages/adminapi.nix {};
        tapop100 = pkgs.python3Packages.callPackage ~/.config/home-manager/modules/packages/tapop100.nix {};
        # TODO: Switch to unstable/wezterm package, build time is too long
        wezterm = pkgs.callPackage ~/.config/home-manager/modules/packages/wezterm.nix {};
        paoutput = pkgs.callPackage ~/.config/home-manager/modules/packages/paoutput.nix {};
        pinentry-rofi = pkgs.callPackage ../../../../../etc/nixos/modules/packages/pinentry-rofi.nix {};
        browserpass = oldversion.browserpass;  # Reference override: https://github.com/NixOS/nixpkgs/issues/236074
        picom = pkgs.picom.overrideAttrs (old: {
          version = "unstable-2023-05-08";
          src = pkgs.fetchFromGitHub {
            owner = "yshui";
            repo = "picom";
            rev = "3aed5599c3f73cbfa53b0249795e76ab07cf9ecd";
            sha256 = "138sn4rjmpckdbklaapkavvq7f5hjp2y428w6n9kxxvylhwk7r2y";
            fetchSubmodules = true;
          };
          buildInputs = old.buildInputs ++ [ pkgs.pcre2 ];
        });
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
      # @Reference sometimes needed
      # allowBroken = true;
    };
  };

  home.packages = with pkgs;
    # Conditionals first
    (if sysconfig.networking.hostName == "innixos" || sysconfig.networking.hostName == "innodellix" then [
      unstable.slack
      unstable.teams
      gnome3.gnome-keyring # needed for teams, thanks MS
      unstable.discord
      unstable.zoom-us
      my_scripts.innovpn-toggle
      thunderbird
    ] else [] ) ++ [

    # Now overrides

    ( gimp-with-plugins.override { plugins = with gimpPlugins; [ gmic ]; })
    ( pass.withExtensions ( ps: with ps; [ pass-genphrase ]))
    ( python3.withPackages ( ps: with ps; [
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
        pyupgrade
        pyyaml
        requests
        setuptools
        tapop100
        vimwiki-markdown
        virtualenv
        xlib
    ]))

    # non-stable stuff, subject to change
    steam
    nur.repos.mic92.reveal-md
    unstable.tdesktop # telegram

    # Rest is sorted
    adbfs-rootless
    alacritty
    alttab
    arandr # I might need manual xrandr one day
    arc-kde-theme # for theming kde apps
    arc-theme
    ark
    blueman
    brightnessctl
    calibre
    chromium
    dconf # some gnome apps keep its config in this shit e.g. shotwell
    ffmpeg
    ffmpegthumbs
    firefox
    flameshot
    geany
    gitstatus
    glxinfo
    graphviz # some rarely-needed weird tools
    grobi # no more autorandr 🎉
    imagemagick
    inotify-tools
    jmtpfs # mount MTP devices easily
    # kde-cli-tools # required to open kde-gtk-config
    # kde-gtk-config # best GTK theme selector
    libnotify
    libreoffice
    lxqt.lximage-qt
    meld # GUI diff tool
    mpv
    my_scripts.bulb-toggle
    my_scripts.git-browse-origin
    my_scripts.git-cleanmerged
    my_scripts.psitool-script
    my_scripts.tarsnap-dotfiles
    my_scripts.workman-toggle
    my_scripts.xinput-toggle
    nfpm
    onboard # on-screen keyboard
    pamixer # pulseaudio mixer
    papirus-icon-theme
    paoutput
    pasystray
    pavucontrol
    pcmanfm-qt # A file-manager which fucking works
    # pdftk # split-combine pdfs
    picom # X compositor which sucks, also do not use services.picom
    pinentry-rofi
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
    update-nix-fetchgit
    wally-cli
    wezterm
    xautomation
    xclip
    xdotool
    xorg.xmodmap
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    xorg.xwininfo
    xournal # annotate pdfs
    xsel
  ];
}
#  vim: set ts=2 sw=2 tw=0 et :
