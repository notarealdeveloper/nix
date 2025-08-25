{ config, lib, pkgs, ... }:

{
  environment.packages = with pkgs; [
    git
    gh
    vim
    findutils
    gnugrep
    gnupg
    gnused
    gnumake
    gnutar
    diffutils
    utillinux
    procps
    killall
    tzdata
    hostname
    man
    iproute2
    bzip2
    gzip
    xz
    zip
    unzip
    cowsay
    figlet
    toilet
    cmatrix
    asciiquarium
    sl
    python313
    home-manager
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  time.timeZone = "America/Chicago";
}
