{ pkgs, lib, config, desktop ? true, ... }:

let
  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";
in {
  imports = [
    (import ./base.nix { inherit lib config pkgs user; })
    ./repos.nix
  ] ++ lib.optionals desktop [ ./desktop.nix ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = name;
    userEmail = email;
    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
    };
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
