{ pkgs, lib, config, ... }:

{

  home.username = "luna";
  home.homeDirectory = "/home/luna";

  home.packages = with pkgs; [
    cowsay
    xcowsay
    figlet
    toilet
    cmatrix
    asciiquarium
    yt-dlp
  ];

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
