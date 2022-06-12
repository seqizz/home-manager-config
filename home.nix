{ pkgs, config, ... }:

with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

{
  imports =
  [
    ./modules/includes.nix
  ];

  home.activation.fuckMicrosoft = dagEntryBefore ["checkLinkTargets"] ''
    echo "Removing the crap some moronic apps are placing.."
    find ~ -name "*.FUCK" -print -delete
  '';

  # XXX: Managing plugins via sheldon, since nix-way is basically
  # "Oh let's write the hashsums of every f-king plugin's every version we use"
  home.activation.updateSheldon = dagEntryAfter ["writeBoundary"] ''
    #!/usr/bin/env zsh

    if [ ! -e /tmp/.sheldon_updated ] || [ `stat --format=%Y /tmp/.sheldon_updated` -le $(( `date +%s` - 86400 )) ]; then
      echo "Updating sheldon plugins.."
      sheldon lock --update || echo "Had problems, ignoring!"
      touch /tmp/.sheldon_updated
    else
      echo "Skipping sheldon update, recently done"
    fi
  '';

  programs.home-manager = {
    enable = true;
  };

  home.stateVersion = "19.03";
}
