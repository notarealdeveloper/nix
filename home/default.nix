{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    #xcowsay
  ];

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
