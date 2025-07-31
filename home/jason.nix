{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";
  gitconfig = (import ./lib/git.nix user name email);

in {

  imports = [
    gitconfig
    ./lib/system.nix
    ./lib/public.nix
    ./lib/private.nix
  ]
  ++
  (pkgs.lib.optional desktop ./lib/desktop.nix)
  ;

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
