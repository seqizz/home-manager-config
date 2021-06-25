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

    ".config/Yubico/YKPersonalization.conf".text = ''
      [Customer]
      Prefix=0
      Used=false

      [Export]
      Filename=/home/gurkan/export.ycfg

      [Flag]
      AllowUpdate=true
      AppendCr=true
      AppendDelay1=false
      AppendDelay2=false
      AppendTab1=false
      AppendTab2=false
      FastTrig=false
      HmacLt64=true
      ManUpdate=false
      OathHotp8=false
      Pacing10ms=false
      Pacing20ms=false
      RequireInput=false
      SerialBtnVisible=true
      StrongPw1=false
      StrongPw2=false
      StrongPw3=false
      TabTirst=false
      UseNumericKeypad=false
      serialApiVisible=true
      serialUsbVisible=false

      [Import]
      Filename=/home/gurkan/import.ycfg

      [Log]
      Disabled=true
      Filename=/home/gurkan/configuration_log.csv
      Format=0

      [Preference]
      Export=false
    '';

    ".ssh/.folder-README".text = ''
      config: Comes from home-manager
      keys:   Comes from syncthing (with exception of *neversync* regex for keys I don't want to sync)
      others: Local files
    '';

    ".zshnix".text = ''
      if ! [[ `ssh-add -L | grep nist` ]] && [[ `lsusb | grep "0406 Yubico"` ]]; then
        if [[ ! -z `pgrep ssh-add` ]]; then
          echo "(There seems to be another instance running)"
        fi
        ssh-add -s ${pkgs.opensc}/lib/opensc-pkcs11.so
      fi
    '';

    ".gist".text = secrets.gistSecret;

    ".tarsnap.key".text = secrets.tarsnapKey;

    ".tarsnaprc".text = ''
      keyfile ~/.tarsnap.key
      print-stats
      cachedir ~/.tarsnapcache
    '';

    ".thunderbird/profiles.ini".text = ''
        [General]
        StartWithLastProfile=1

        [Profile0]
        Name=default
        IsRelative=1
        Path=gurkan.default
        Default=1
    '';

    ".thunderbird/gurkan.default/user.js".text = ''
      user_pref("mailnews.default_news_sort_order", 2);
      user_pref("mailnews.default_news_sort_type", 18);
      user_pref("mailnews.default_sort_order", 2);
      user_pref("beacon.enabled", false);
    '';

    ".thunderbird/gurkan.default/chrome/userChrome.css".text = ''
      /* Set default namespace to XUL */
      @namespace
      url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

      /* Set font size in folder pane */
      #folderTree >treechildren::-moz-tree-cell-text {
          font-size: 12pt !important;
      }

      /* Set font size in thread pane */
      #threadTree >treechildren::-moz-tree-cell-text {
          font-size: 12pt !important;
      }

      /* Set height for cells in folder pane */
      #folderTree >treechildren::-moz-tree-row {
        height: 25px !important;
      }

      /* Set height for cells in thread pane */
      #threadTree >treechildren::-moz-tree-row {
        height: 25px !important;
      }
    '';

    ".mozilla/firefox/installs.ini".text = ''
        [72C951DA6087EB20]
        Default=gurkan.default
        Locked=1
    '';

    ".mozilla/firefox/profiles.ini".text = ''
      [Install72C951DA6087EB20]
      Default=gurkan.default
      Locked=1

      [Profile0]
      Name=gurkan.default
      IsRelative=1
      Path=gurkan.default
      Default=1

      [General]
      StartWithLastProfile=1
      Version=2
    '';

    ".mozilla/firefox/gurkan.default/user.js".text = ''
      user_pref("app.normandy.first_run", false);
      user_pref("app.shield.optoutstudies.enabled", false);
      user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr", false);
      user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
      user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
      user_pref("browser.newtabpage.activity-stream.disableSnippets", true);
      user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
      user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
      user_pref("browser.pocket.enabled", false);
      user_pref("browser.tabs.warnOnClose", false);
      user_pref("browser.download.useDownloadDir", false);
      user_pref("browser.urlbar.clickSelectsAll", true);
      user_pref("browser.urlbar.doubleClickSelectsAll", false);
      user_pref("dom.webnotifications.enabled", false);
      user_pref("extensions.pocket.enabled", false);
      user_pref("general.warnOnAboutConfig", false);
      user_pref("security.webauth.u2f", true);
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      user_pref("browser.tabs.closeWindowWithLastTab", false);
      user_pref("browser.cache.disk.smart_size.enabled", false);
      user_pref("browser.cache.disk.capacity", 500000);
      user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
      user_pref("privacy.trackingprotection.cryptomining.enabled", true);
      user_pref("browser.toolbars.bookmarks.showOtherBookmarks", false);
      user_pref("browser.cache.disk.capacity", 100000);
      user_pref("dom.w3c_touch_events.enabled", 1);
    '';

    ".mozilla/firefox/gurkan.default/chrome/userChrome.css".text = ''
      #TabsToolbar {
              visibility: collapse !important;
      }

      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
              display: none;
      }
      /*
      #sidebar-box, #sidebar-box *{ max-width:5em; min-width:50px;}
      #sidebar-box:hover, #sidebar-box:hover *{ max-width:none!important;}
      */

      :root {
        --sidebar-normal-width: 150px;
        --sidebar-hover-width: 250px;
        --background-color: rgb(0,0,0);
      }

      #sidebar-box {
        position: relative !important;
        overflow-x: hidden !important;
        min-width: var(--sidebar-normal-width) !important;
        max-width: var(--sidebar-normal-width) !important;
        -moz-transition: all .2s ease-out .2s !important;
      }

      #sidebar-box:hover {
        margin-left: calc((var(--sidebar-hover-width) - var(--sidebar-normal-width)) * -1) !important;
        min-width: var(--sidebar-hover-width) !important;
        -moz-transition: all .2s ease-out 2s !important;
      }
      #sidebar-splitter {
          display: none !important;
      }

      /*
      * fullscreen hide
      #main-window[inFullscreen] #sidebar-box {
          display:none !important;
          width: 0px !important;
      }
      */
    '';
    ".config/greenclip.cfg".text = ''
      Config {
        maxHistoryLength = 200,
        historyPath = "~/.cache/greenclip.history",
        staticHistoryPath = "~/.cache/greenclip.staticHistory",
        imageCachePath = "/tmp/",
        usePrimarySelectionAsInput = False,
        blacklistedApps = [],
        trimSpaceFromSelection = True
      }'';

    ".trc".text = secrets.rubyTwitterSecret;

    ".config/tig/config".text = ''
        # Switch to a branch with selected commit
        bind generic n !@sh -c "git checkout -b `echo -n %(commit) | head -c 10 | sed 's/^/newbranch_/'` %(commit)"

        # copy commit id to clipboard
        bind generic c !@sh -c "echo -n %(commit) | xclip -selection c"

        # export current diff to a file
        bind generic S ?git format-patch -1 -N %(commit)
    '';

    ".config/alacritty/alacritty.yml".text = ''
      env:
        TERM: xterm-256color

      window:
        decorations: none

      font:
        normal:
          family: "Fira Code"
        bold:
          family: "Fira Code"
          style: Bold
        italic:
          family: "Fira Code"
          style: Italic
        size: 10.0

      draw_bold_text_with_bright_colors: true

      colors:
        primary:
          foreground: '0xeaeaea'

      background_opacity: 0.95

      mouse:
        hide_when_typing: true
        url:
          modifiers: Control

      selection:
        semantic_escape_chars: ",│`|:\"' ()[]{}<>"

      window.dynamic_title: true

      cursor:
        style: Block
        unfocused_hollow: true

      live_config_reload: true

      key_bindings:
        - { key: Key0,     mods: Control,       action: ResetFontSize    }
        - { key: Key4,   mods: Control,       action: IncreaseFontSize }
        - { key: Minus,    mods: Control,       action: DecreaseFontSize }
    '';

    ".config/picom.conf".text = ''
      inactive-opacity = 1.0;
      active-opacity = 1;
      frame-opacity = 1;

      blur-background = true;
      blur-background-fixed = true;
      blur:
      {
        method = "gaussian";
        size = 10;
        deviation = 5.0;
      };

      no-fading-openclose = true;
      use-ewmh-active-win = true;
      detect-client-opacity = true;

      backend = "glx";

      # slock
      focus-exclude = [
          "! name ~= ''\'' "
      ];

      shadow = true;
      shadow-radius = 5;
      shadow-offset-x = -5;
      shadow-offset-y = -5;
      shadow-opacity = 0.5;
      shadow-exclude = [
          "class_g = 'Firefox' && argb",
          "class_g = 'TelegramDesktop' && argb",
          "_NET_WM_WINDOW_TYPE:a = '_NET_WM_WINDOW_TYPE_NOTIFICATION'",
          "class_g = 'Daily' && argb",
          "class_g = 'Mail' && argb"
      ];
    '';

    ".proxychains/proxychains.conf".text = ''
      quiet_mode
      [ProxyList]
      socks5 127.0.0.1 8080
    '';

    ".config/pylintrc".text = ''
      [LOGGING]
      disable=logging-format-interpolation
    '';
  };
}
