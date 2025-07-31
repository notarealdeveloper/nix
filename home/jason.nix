{ pkgs, lib, config, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

in {

  imports = [
   (./lib/git.nix user name email)
    ./lib/github-public.nix
    ./lib/github-private.nix
    ./lib/desktop.nix
    ./lib/common.nix
  ];

}
