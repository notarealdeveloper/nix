{ pkgs, lib, config, ... }:

let

  user = "ramya";
  name = "Ramya Kottaplli";
  email = "rskottap@gmail.com";
  gitconfig = (import ./lib/git.nix user name email);

in {

  imports = [
    gitconfig
    ./lib/system.nix
    ./lib/public.nix
  ];

  # Keep this line
  home.stateVersion  = "25.05";

}
