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

}
