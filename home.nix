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

  # @Reference doesn't work with new versions
  # home.activation.fuckMicrosoft = dagEntryBefore ["checkLinkTargets"] ''
    # echo "Removing the crap some moronic apps are placing.."
    # find ~ -name "*.FUCK" -print -delete
  # '';

  programs.home-manager = {
    enable = true;
  };

  home.stateVersion = "19.03";
}
