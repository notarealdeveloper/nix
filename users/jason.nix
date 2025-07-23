{ pkgs, ... }:

{
  home.username      = "jason";
  home.homeDirectory = "/home/jason";
  home.stateVersion  = "25.05";   # keep this line

  programs.git = {
    enable    = true;
    userName  = "Jason Wilkes";
    userEmail = "notarealdeveloper@gmail.com";

    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase        = true;
    };
  };

  home.packages = with pkgs; [

    # terminal
    asciiquarium
    cmatrix
    figlet
    toilet

    # lean
    #elan
    lean4
  ];
}
