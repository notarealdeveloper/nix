user:

{ pkgs, lib, config, ... }:

{
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
}
