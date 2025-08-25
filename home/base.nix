# Base configuration shared by all users
{ lib, config, pkgs, user, ... }:

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.05";
  news.display = "silent";

  # Common packages that all users need
  home.packages = with pkgs; [
    git
    dconf
    inotify-tools
  ];

  # Basic bash configuration
  programs.bash.enable = true;
}
