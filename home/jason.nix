{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

in {

  imports = [
    (import ./lib/git.nix user name email)
    ./lib/public.nix
    ./lib/private.nix
  ]
  ++
    (if desktop then [./lib/desktop.nix] else [])
  ;

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
