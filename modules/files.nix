{ pkgs, ... }:
let
  sync = "/home/gurkan/syncfolder";
  secrets = import ./secrets.nix {pkgs=pkgs;};
  fileAssociations = import ./file-associations.nix;
in
{
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = fileAssociations;
    };
    configFile."mimeapps.list".force = true;
  };

  home.file = {
    # Static stuff
    ".config/Yubico/u2f_keys".text = secrets.yubicoU2FKeys;
    ".config/Yubico/YKPersonalization.conf".source = ./config_files/YKPersonalization.conf;

    ".zshnix".source = ./config_files/zsh_nix;

    ".gist".text = secrets.gistSecret;

    ".tarsnap.key".text = secrets.tarsnapKey;

    ".tarsnaprc".source = ./config_files/tarsnaprc;

    ".thunderbird/profiles.ini".source = ./config_files/thunderbird/profiles.ini;
    ".thunderbird/gurkan.default/user.js".source = ./config_files/thunderbird/user.js;
    ".thunderbird/gurkan.default/chrome/userChrome.css".source = ./config_files/thunderbird/userChrome.css;

    ".mozilla/firefox/installs.ini".source = ./config_files/firefox/installs.ini;
    ".mozilla/firefox/profiles.ini".source = ./config_files/firefox/profiles.ini;
    ".mozilla/firefox/gurkan.default/user.js".source = ./config_files/firefox/user.js;
    ".mozilla/firefox/gurkan.default/chrome/userChrome.css".source = ./config_files/firefox/userChrome.css;

    ".config/greenclip.toml".source = ./config_files/greenclip.toml;

    ".config/clipcat/clipcat-menu.toml".source = ./config_files/clipcat-menu.toml;
    ".config/clipcat/clipcatd.toml".source = ./config_files/clipcatd.toml;

    ".trc".text = secrets.rubyTwitterSecret;

    ".config/tig/config".source = ./config_files/tig;

    ".config/picom.conf".source = ./config_files/picom.conf;

    ".proxychains/proxychains.conf".source = ./config_files/proxychains.conf;

    ".config/pylintrc".source = ./config_files/pylintrc;
  };
}
