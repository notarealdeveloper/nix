# nixos on wsl

{ config, lib, pkgs, ... }:

{

  wsl.enable = true;
  wsl.defaultUser = "jason";
  system.stateVersion = "24.11";

}
