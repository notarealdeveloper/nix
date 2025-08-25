{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";
  common    = (pkgs.callPackage ./common.nix { inherit user; });
  gitconfig = (import ./lib/git.nix name email);

  system = import ./lib/system.nix { inherit pkgs lib config; };
  inherit (system) nixos exec personal;

in {

  imports = [
    common
    gitconfig
    ./lib/public.nix
    ./lib/private.nix
    (if desktop then ./lib/desktop.nix else ./lib/none.nix)
  ];

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  # Keep this line
  home.stateVersion  = "25.05";
}
