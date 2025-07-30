{ pkgs, lib, config, ... }:

let

  user = "ramya";
  name = "Ramya Kottapalli";
  email = "ramya@thedynamiclinker.com";

in

(import ./default.nix { inherit pkgs lib config; }) // {

  home.username = user;
  home.homeDirectory = "/home/${user}";

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

}
