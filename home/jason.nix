{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

in {

  imports = [
    (import ./lib/git.nix user name email)
    ./lib/github-public.nix
    ./lib/github-private.nix
    ./lib/common.nix
  ]
  ++ (pkgs.lib.optional desktop ./lib/desktop.nix)
  ;
}
