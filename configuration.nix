# run nixos-help or man configuration.nix for more info

{ config, pkgs, ... }:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [ ./system76.nix ];

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # hostname
  networking.hostName = "turing";

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
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:escape";
  };
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.gtk = {
      enable = true;
      #theme = {
      #  package = pkgs.arc-theme;
      #  name = "Arc-Dark";
      #};
      #cursorTheme = {
      #  package = pkgs.vanilla-dmz;
      #  name = "Vanilla-DMZ";
      #  size = 24;
      #};
    };
    greeters.slick.enable = false; # is it a bug that this is required? find out :)
  };

  # desktop
  services.xserver.desktopManager.cinnamon.enable = true;

  # cups
  services.printing.enable = true;

  # sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # system
  environment.systemPackages =
  
    let

      python = pkgs.python313;

    in

    with pkgs; [

    # nix
    nix-bash-completions
    nix-prefetch-github
    home-manager
    dconf2nix

    # unix
    #vim_configurable
    vim
    file
    wget
    plocate
    git
    gh
    jq

    # silly
    cowsay
    xcowsay
    asciiquarium
    cmatrix
    figlet
    toilet
    sl
    sl2

    # dev
    gcc
    gnumake
    adbfs-rootless
    lean4
    elan

    # debugging
    gdb
    strace
    ltrace
    patchelf
    inotify-tools

    # mid-level
    xclip
    xdotool
    imagemagick

    # crypt
    tor
    torsocks
    tor-browser

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
    vscode
    obsidian

    # video
    vlc
    ffmpeg
    kdePackages.kdenlive
    simplescreenrecorder

    # net
    dropbox
    dropbox-cli
    openvpn3
    openssh

    # social
    wechat
    whatsapp-for-linux
    teams-for-linux

    # games
    stepmania

    /* THE IMPORT VS EXEC ISSUE */

    yello

    (python.withPackages (ps: with ps; [

      # packaging
      pip
      setuptools
      build
      twine
      pytest

      # basics
      ipython
      requests

      # net
      beautifulsoup4
      yt-dlp

      # numerical
      numpy
      scipy
      pandas
      scikit-learn
      matplotlib
      seaborn
      torch

      # ~/bin depends
      google-auth-oauthlib      # gmail
      google-api-python-client  # getbtcprice
      geoip2                    # getbtcprice

      # overlay
      is_instance
      embd
      wnix
      jello

    ]))

    python314FreeThreading

    # So close!
    # python-head

    (import ./python311.nix pkgs)

  ];

  # users
  users.users.jason = {
    isNormalUser = true;
    description = "Jason";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    packages = with pkgs; [
    ];
  };

  # groups
  users.extraGroups.plocate.members = [ "jason" ];

  # Android Debug Bridge
  programs.adb.enable = true;

  # Vim: clipboard support
  programs.vim = {
    enable = true;
    package = pkgs.vim;  # this is the default full-featured vim with +clipboard
  };

  # dconf
  programs.dconf.enable = true;
  environment.shellInit = ''
    dconf write /org/nemo/preferences/default-folder-viewer "'list-view'"
  '';

  # git
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
        commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; }
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

  # net
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  programs.openvpn3.enable = true;

  # don't change this
  system.stateVersion = "25.05";

}
