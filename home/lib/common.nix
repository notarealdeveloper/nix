{ pkgs, lib, config, ... }:

{

  nixpkgs.config.allowUnfree = true;

  # Keep this line
  home.stateVersion  = "25.05";

}
