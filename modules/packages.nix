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
  nixpkgs = {
    config = {
      enable = true;
      allowUnfree = true;
      # Quick-overrides
      packageOverrides = pkgs: rec {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
        adminapi = unstable.python3Packages.callPackage /devel/ig/nix-definitions/packages/adminapi.nix {};
        tapop100 = unstable.python3Packages.callPackage ~/.config/nixpkgs/modules/packages/tapop100.nix {};
        wezterm = pkgs.callPackage ~/.config/nixpkgs/modules/packages/wezterm.nix {};
        paoutput = pkgs.callPackage ~/.config/nixpkgs/modules/packages/paoutput.nix {};
        picom = pkgs.picom.overrideAttrs (old: {
          version = "unstable-2022-02-05";
          src = pkgs.fetchFromGitHub {
            owner = "yshui";
            repo = "picom";
            rev = "928963721c8789fc5f27949e8b0730771aab940d";
            sha256 = "1ri3fcgf2v1pbf9kss148z66zmgy25d5nvh79bi0cmdr86flgvxa";
            fetchSubmodules = true;
          };
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
      slack
      unstable.teams
      gnome3.gnome-keyring # needed for teams, thanks MS
      discord
      zoom-us
      my_scripts.innovpn-toggle
      thunderbird
    ] else [] ) ++ [

    # Now overrides

    ( gimp-with-plugins.override { plugins = with gimpPlugins; [ gmic ]; })
    ( pass.withExtensions ( ps: with ps; [ pass-genphrase ]))
    ( unstable.python3.withPackages ( ps: with ps; [
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
    ffmpeg
    ffmpegthumbs
    firefox
    flameshot
    geany
    gitstatus
    glxinfo
    gnome3.dconf # some gnome apps keep its config in this shit e.g. shotwell
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
    my_scripts.git-cleanmerged
    my_scripts.psitool-script
    my_scripts.tarsnap-dotfiles
    my_scripts.xinput-toggle
    my_scripts.workman-toggle
    onboard # on-screen keyboard
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
    update-nix-fetchgit
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
