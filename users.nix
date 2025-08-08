{ pkgs, lib, config, ... }:

{

  # users
  users.users.jason = {
    isNormalUser = true;
    description = "Jason";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    packages = with pkgs; [
    ];
  };

  users.users.ramya = {
    isNormalUser = true;
    description = "Ramya";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  users.users.mei = {
    isNormalUser = true;
    description = "Mei";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  users.users.luna = {
    isNormalUser = true;
    description = "Luna";
    extraGroups = [ "audio" "video" ];
    packages = with pkgs; [
      yt-dlp
      vlc
    ];
  };

  # groups
  users.extraGroups.plocate.members = [ "jason" "ramya" "mei" ];

  security.sudo = {
    enable = true;
    extraRules = [
      #{ users = [ "jason" ]; commands = []; }
      { users = [ "jason" ]; commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ]; }
    ];
  };

  # git (system level)
  environment.etc."gitconfig".text = ''
    [user]
      name = Jason Wilkes
      email = root@thedynamiclinker.com
    [init]
      defaultBranch = master
    [pull]
      rebase = true
  '';

}
