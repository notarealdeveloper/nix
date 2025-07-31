{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "ramya";
  name = "Ramya Kottaplli";
  email = "rskottap@gmail.com";
  common    = (import ./common.nix user);
  gitconfig = (import ./lib/git.nix name email);

in {

  imports = [
    common
    gitconfig
    ./lib/public.nix
    (if desktop then ./lib/desktop.nix else ./lib/none.nix)
  ];

  # Keep this line
  home.stateVersion  = "25.05";

}
