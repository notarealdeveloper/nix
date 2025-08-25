{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

in {

  home.packages = with pkgs; [
    git
    dconf
    inotify-tools
  ];

  imports =
    [ (import ./base.nix { inherit user; }) ]
    ++
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
}
