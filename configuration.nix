# for help, see nixos-help or man nix.conf

{ config, lib, pkgs, ... }:

{

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 64*(1024*1024);
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
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:escape";
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
    vim_configurable
    file
    wget
    tree
    plocate
    git
    gh
    jq
    acpi

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
    ranger
    adbfs-rootless
    lean4

    # debugging
    gdb
    strace
    ltrace
    patchelf
    inotify-tools
    pkg-config

    # mid-level
    xorg.xinit
    xorg.xeyes
    xclip
    xdotool
    imagemagick

    # crypt
    tor
    torsocks
    tor-browser
    cryptsetup

    # desktop
    conky
    eog
    meld
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
    openvpn3
    openssh

    # social
    wechat
    whatsapp-for-linux
    teams-for-linux

    # games
    stepmania

    # raw derivations
    sayhi   # stdenv.mkDerivation, depends on hi
    saybye  # builtins.derivation, depends on raw bye
    yello   # attempt to declare an importable that depends on an executable

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

    python311
    glab

    # So close!
    # python-head

  ];

  # android debug bridge
  programs.adb.enable = true;

  # dconf
  programs.dconf.enable = true;

  # vim: clipboard support
  programs.vim = {
    enable = true;
    package = pkgs.vim;  # this is the default full-featured vim with +clipboard
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

}
