# native nixos

{ config, lib, pkgs, ... }:

{

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.gtk.enable = true;
    greeters.slick.enable = false; # is it a bug that this is required? find out :)
  };

  programs.dbus.enable = true;

  system.stateVersion = "25.05";
}
