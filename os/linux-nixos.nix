# native nixos

{ config, lib, pkgs, ... }:

let
  consoleFont = pkgs.runCommand "LatGrkCyr-16x32.psfu" {
    nativeBuildInputs = [ pkgs.psftools ];
  } ''
    gzip -dc ${pkgs.kbd}/share/consolefonts/LatGrkCyr-8x16.psfu.gz \
      | psfxform --scale --width=16 --height=32 --psf2 > "$out"
  '';
in

{

  console.font = "${consoleFont}";

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

  system.stateVersion = "25.05";
}
