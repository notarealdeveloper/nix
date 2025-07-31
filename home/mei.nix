{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "mei";
  name = "Mei Mei Wilkes";
  email = "meimei85768@gmail.com";
  common    = (import ./common.nix user);
  gitconfig = (import ./lib/git.nix name email);

in {

  imports = [
    common
    gitconfig
    ./lib/public.nix
    (if desktop then ./lib/desktop.nix else ./lib/none.nix)
  ];

  home.packages = with pkgs; [
    cowsay
    lolcat
  ];

  # Keep this line
  home.stateVersion  = "25.05";

}

