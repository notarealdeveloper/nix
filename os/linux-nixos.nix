# native nixos

{ config, lib, ... }:

let

  pkgs = import <nixpkgs> {}; # we're --impure
  sysVendor = builtins.unsafeDiscardStringContext (pkgs.runCommandLocal "get-sys-vendor" {} ''
    cat /sys/class/dmi/id/sys_vendor > $out
  '');
  #sysVendor  = builtins.unsafeDiscardStringContext (builtins.readFile /sys/class/dmi/id/sys_vendor);
  isLenovo   = sysVendor == "LENOVO\n";
  isSystem76 = sysVendor == "To be determined...\n";

in {

  imports = [(
    if isLenovo
    then ../hardware/lenovo.nix
    else
    if isSystem76
    then ../hardware/system76.nix
    else ../hardware/none.nix
  )];

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
