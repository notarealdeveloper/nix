{ lib, config, user, ... }:

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  news.display = "silent";

  # Common packages that all users need
  home.packages = with pkgs; [
    git
    dconf
    inotify-tools
  ];

  # Basic bash configuration
  programs.bash.enable = true;

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  # Don't delete this
  home.stateVersion = "25.05";
}
