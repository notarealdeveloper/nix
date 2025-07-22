# Edit this configuration file to define what should be installed on your system.
# Help is available in the configuration.nix(5) man page and in the NixOS manual
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [
      ./hardware/system76.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set hostname.
  networking.hostName = "turing";

  # Set your time zone.
  time.timeZone = "America/Chicago";

  environment.variables = {
    EDITOR = "vim";
  };

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

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      accelProfile = "adaptive";
      accelSpeed = "0.5";
    };
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
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

  # Enable CUPS
  services.printing.enable = true;

  # Enable sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages =
  
    let

      hello = (import ./bin/hello.nix { inherit (pkgs) stdenv fetchFromGitHub; });

    in

    with pkgs; [

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
    imagemagick
    pcre
    jq

    # desktop
    nemo
    conky
    eog
    gedit
    evince
    google-chrome
    gnome-terminal
    numix-gtk-theme
    numix-icon-theme-circle

    # nix
    nix-bash-completions
    nix-prefetch-github

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

    # dev lean
    elan
    lean4

    # ld
    dropbox
    dropbox-cli
    openvpn3
    openssh

    # dev python: let's get python 3.14 without the GIL
    python314FreeThreading

    # dev python: no venvs bitch
    (pkgs.python313.withPackages (import ./python))

    # import vs exec issue
    hello

  ];

  # Define a user
  users.users.jason = {
    isNormalUser = true;
    description = "Jason";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  # Enable docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Vim: clipboard support
  programs.vim = {
    enable = true;
    package = pkgs.vim;  # this is the default full-featured vim with +clipboard
  };

  # Enable some programs
  programs.dconf.enable = true;
  programs.openvpn3.enable = true;

  # Extra groups
  users.extraGroups.docker.members = [ "jason" ];
  users.extraGroups.plocate.members = [ "jason" ];

  # Shell init
  environment.shellInit = ''
    dconf write /org/nemo/preferences/default-folder-viewer "'list-view'"
  '';

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
    [user]
      name = Jason Wilkes
      email = notarealdeveloper@gmail.com
    [init]
      defaultBranch = master
    [pull]
	    rebase = true
  '';

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ "jason" ];
        commands = [
          #{
          #  command = "/run/current-system/sw/bin/vim";
          #  options = [ "NOPASSWD" ];
          #}
          #{
          #  command = "/run/current-system/sw/bin/nixos-rebuild";
          #  options = [ "NOPASSWD" ];
          #}
          {
            command = "ALL";
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

  # Networking.
  networking.networkmanager.enable = true;

  networking.networkmanager.plugins = [
    pkgs.networkmanager-openvpn
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
