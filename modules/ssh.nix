{config, pkgs, ...}:
let
  secrets = import ./secrets.nix {pkgs=pkgs;};
in
{
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;
    hashKnownHosts = true;
    matchBlocks = secrets.sshMatchBlocks;
  };

  home.file.".ssh/.folder-README".text = ''
    config: Comes from home-manager
    keys:   Comes from syncthing (with exception of *neversync* regex for keys I don't want to sync)
    others: Local files
  '';
}
