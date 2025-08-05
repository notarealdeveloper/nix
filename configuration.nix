# for help, see nixos-help or man nix.conf

{ config, lib, pkgs, ... }:

let

  python311submissive = pkgs.python311.overrideAttrs (pkg: {
    postInstall = (pkg.postInstall or "") + ''
      ${pkgs.cowsay}/bin/cowsay "Here we go!"
      for file in $(ls "$out/bin"); do
        if [[ "$file" == python3.11 ]]; then
          continue
        fi
        rm -v "$out/bin/$file"
      done
      rm -rv $out/share
      echo "$out now contains:"
      for f in $(find $out/ -type f); do echo " * $f"; done
      ${pkgs.cowsay}/bin/cowsay \
        "Nothing beside remains... " \
        "The lone and level s&&s stretch far away."
    '';
  });

in
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
    unzip
    plocate
    git
    gh
    glab
    jq
    acpi

    # dev
    gcc
    gnumake
    ranger
    adbfs-rootless
    android-udev-rules
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
    sshfs
    thc-secure-delete
    nasm

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
    ffmpegthumbnailer
    vscode
    obsidian
    gimp

    # video
    vlc
    ffmpeg
    kdePackages.kdenlive
    simplescreenrecorder

    # net
    dropbox
    openvpn3
    openssh
    nmap

    # social
    wechat
    whatsapp-for-linux
    teams-for-linux

    # games
    stepmania

    (python.withPackages (ps: with ps; [

      # packaging
      pip
      setuptools

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

    #python314FreeThreading

    # So close!
    # python-head

    # raw derivations
    sayhi   # stdenv.mkDerivation, depends on hi
    saybye  # builtins.derivation, depends on raw bye
    yello   # attempt to declare an importable that depends on an executable

    # ascii
    cowsay
    xcowsay
    asciiquarium
    cmatrix
    neofetch
    figlet
    toilet
    sl
    sl2

    # ports
    weatherspect

    (pkgs.perl.withPackages (ps: with ps; [
      TermAnimation
      JSON
      LWP
    ]))

    #python311submissive
    python311

    # experiment
    awscli2
    gitlab-ci-local

    # <abominations>
    ## This little guy (1) installs X11 when
    ## you install numpy, (2) downgrades
    ## your python version in non-commutative
    ## ways, and (3) modifies /proc/self/root
    ## such that you see a different set of
    ## directories when you `ls /`, and does
    ## so without requiring root. Clearly some
    ## kind of call to `unshare` or something
    ## else that's practically equivalent to
    ## a sizable subset of docker.
    conda
    ## <QUARANTINE>
    ### > But He turned and said unto Ptr
    ### > "Get thee behind Me, Satan!
    ### > Thou art an offense unto Me;
    ### > for thou savorest not the things
    ### > that be of /bin, but those that
    ### > be of /opt/apps/docker/prod/lib/conda/env/bin
    ### > -Matthew 16:23
    poetry
    ### Don't touch me poetry.
    ### I'm just using you to make a point.
    ## </QUARANTINE>
    # </abominations>

    # bash bug
    fish
    dash
    tcsh
    ksh
    zsh
  ];

  # android debug bridge
  programs.adb.enable = true;

  # dconf
  programs.dconf.enable = true;

  # hell yeah
  #programs.nix-ld.enable = true;
  #programs.nix-ld.libraries = with pkgs; [
  #  gcc
  #  zlib
  #  glibc
  #  gcc.cc.lib
  #];

  gtk.iconCache.enable = false;

  # vim: clipboard support
  programs.vim = {
    enable = true;
    package = pkgs.vim_configurable;  # this is the default full-featured vim with +clipboard
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
