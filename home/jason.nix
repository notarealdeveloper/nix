{ pkgs, lib, config, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

in {

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
