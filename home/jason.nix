{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

  src = pkgs.callPackage ./src.nix { };
  inherit (src) nix exec personal;

in {

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  news.display = "silent";

  imports =
    [ ./public.nix ./private.nix ]
    ++
    (if desktop then [ ./desktop.nix ] else [])
  ;


  # ~/.config/git
  programs.git = {
    enable    = true;
    userName  = name;
    userEmail = email;
    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
    };
  };

  # ~/.config/gh
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  # Keep this line
  home.stateVersion  = "25.05";
}
