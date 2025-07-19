# Edit this configuration file to define what should be installed on your system.
# Help is available in the configuration.nix(5) man page and in the NixOS manual
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "turing";    # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      accelProfile = "adaptive";
      accelSpeed = "0.5";
    };
  };

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.gtk = {
      enable = true;
      theme = {
        package = pkgs.arc-theme;
        name = "Arc-Dark";
      };
      cursorTheme = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
        size = 24;
      };
    };
    greeters.slick.enable = false; # is it a bug that this is required? find out :)
  };

  # Enable cinnamon desktop
  services.xserver.desktopManager.cinnamon.enable = true;

  # Enable the KDE desktop
  #services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:escape";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.plocate = {};

  users.users.jason = {
    isNormalUser = true;
    description = "Jason";
    extraGroups = [ "networkmanager" "wheel" "plocate" ];
    packages = with pkgs; [
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable overlays
  nixpkgs.overlays = [
    (import ./overlays/mathlib.nix)
  ];

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [

    # tty
    vim_configurable
    wget
    gcc
    git
    gh
    gnumake
    plocate
    xclip
    xdotool
    cowsay
    xcowsay
    inotify-tools

    # desktop
    dconf
    nemo
    conky
    eog
    gedit
    evince
    dropbox
    google-chrome
    gnome-terminal
    numix-gtk-theme
    numix-icon-theme-circle
    nix-bash-completions

    # video
    vlc
    ffmpeg
    kdePackages.kdenlive
    simplescreenrecorder

    # games
    stepmania

    # social
    wechat
    whatsapp-for-linux
    teams-for-linux

    # crypt
    tor
    torsocks
    tor-browser

    # dev
    vscode
    obsidian

    ## lean
    elan
    lean4
    lean4Mathlib

    ## python: no venvs bitch
    (import ./python.nix pkgs)

    ## python: let's get python 3.14 without the GIL
    python314FreeThreading

  ];

  programs.dconf.enable = true;

  # Vim: clipboard support
  programs.vim = {
    enable = true;
    package = pkgs.vim;  # this is the default full-featured vim with +clipboard
  };

  environment.shellInit = ''
    dconf write /org/nemo/preferences/default-folder-viewer "'list-view'"
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Git config
  # This should really be done with home-manager,
  # but we're not there yet. Once we get there, do this:
  #
  # programs.git = {
  #   enable = true;
  #   userName = "Jason Wilkes";
  #   userEmail = "notarealdeveloper@gmail.com";
  # };

  environment.etc."gitconfig".text = ''
    [init]
      defaultBranch = master

    [user]
      name = Jason Wilkes
      email = notarealdeveloper@gmail.com
  '';

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ "jason" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/vim";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # Create autostart .desktop files for programs
  # that should be automatically started by all
  # desktop environments
  environment.etc."xdg/autostart/conky.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Conky
    Exec=conky-smart-start
    X-GNOME-Autostart-enabled=true
    NoDisplay=false
    Comment=Start Conky at login
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
