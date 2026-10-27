# Shared desktop and shell essentials. The full configuration imports this module.
# Hardware and hostname are selected by flake.nix, never by this file.
{ pkgs, ... }:

{
  # Cinnamon itself is installed by services.xserver.desktopManager.cinnamon.
  # Keep large Python environments, TeX, book fonts and full-only apps out of here.
  environment.systemPackages = with pkgs; [
    git
    gh
    google-chrome
    gnumake
    stdenv.cc
    vim-full
    gnome-terminal
    tmux
    ranger
    curl
    wget
    openssh
    gnupg
    pinentry-gnome3
    ripgrep
    jq
    tree
    file
    unzip
    zip
    p7zip
    rsync
    htop
    lsof
    pciutils
    cryptsetup
    btrfs-progs
    e2fsprogs
    dosfstools
    efibootmgr
    xclip
    xdotool
    inotify-tools
    man-pages
    cowsay
    home-manager
    codex
    python3
    perl
    which
  ];

  networking.networkmanager.enable = true;
  services.tailscale.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
    download-buffer-size = 64*(1024*1024);
    max-jobs = "auto";
    cores = 0; # 0 = give each build all cores (build systems may or may not use them)
    http-connections = 50;  # faster parallel downloads
  };

  # time
  time.timeZone = "America/Chicago";

  environment.variables = {
    EDITOR = "vim";
  };

  # internationalisation
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      accelProfile = "adaptive";
      accelSpeed = "0.5";
    };
  };

  # x11 (todo: wayland)
  services.xserver = {
    enable = true;
    xkb = {
      options = "caps:escape";
      layout  = "us,ara,il,in,in,ru,gr";
      variant = ",mac-phonetic,phonetic,hin-kagapa,tel-kagapa,phonetic,";
    };
  };

  # desktop
  services.xserver.desktopManager.cinnamon.enable = true;

  # sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # login keyring
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;      # harmless if you don't use gdm
  security.pam.services.lightdm.enableGnomeKeyring = true;  # harmless if you don't use lightdm

  # this combination seems to work best
  services.gnome.gcr-ssh-agent.enable = true;   # keyring for ssh keys
  services.gnome.gnome-keyring.enable = true;   # keyring for browser/passwords

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  hardware.graphics.enable = true;

  # dconf
  programs.dconf.enable = true;

  gtk = {
    iconCache.enable = false; # i forget what this is for
  };

  # vim: clipboard support
  programs.vim = {
    enable = true;
    package = pkgs.vim-full;  # this is the default full-featured vim with +clipboard
  };

  # users
  users.users.user = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    packages = with pkgs; [
    ];
  };

  users.users.jason = {
    isNormalUser = true;
    description = "Jason";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    packages = with pkgs; [
    ];
  };

  users.users.luna = {
    isNormalUser = true;
    description = "Luna";
    extraGroups = [ "audio" "video" ];
    packages = with pkgs; [
    ];
  };

  # groups
  users.extraGroups.plocate.members = [ "user" "jason" ];

  security.sudo = {
    enable = true;
    extraRules = [
      { users = [ "user" "jason" ]; commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ]; }
    ];
  };

  # git (system level)
  environment.etc."gitconfig".text = ''
    [user]
      name = "Jason Wilkes"
      email = notarealdeveloper@gmail.com
    [init]
      defaultBranch = master
    [pull]
      rebase = true
    [commit]
      verbose = true
  '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # bluetooth
  hardware.bluetooth = {
    enable = true;  # loads btusb
    powerOnBoot = true;
    # Turn off BlueZ privacy if the adapter throws 0x03 errors
    settings.General.Privacy = "off";
  };

  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };

  security.polkit.enable = true;

}
