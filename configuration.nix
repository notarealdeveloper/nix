# for help, see nixos-help or man nix.conf

{ config, lib, wpkgs, pkgs, aws-cvpn-client, ... }:

{

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
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

      python_large = ps: with ps; [
          # packaging
          pip
          build
          twine
          pytest
          cython
          setuptools

          # basics
          ipython

          # net
          yt-dlp
          requests
          beautifulsoup4

          # numerical
          numpy
          scipy
          pandas
          matplotlib
          seaborn
          #scikit-learn

          # ~/bin depends
          google-auth-oauthlib      # gmail
          google-api-python-client  # getbtcprice
          geoip2                    # getbtcprice

          # overlay
          mmry
          assure
          is_instance
          python-bin

      ];

      python_small = ps: with ps; [
      ];

    in

    with pkgs; [

    # unix
    gh
    git
    wget
    tree
    pcre
    acpi
    plocate

    # formats
    jq
    file
    cpio
    unzip

    # build
    gcc
    nasm
    clang
    gnumake
    gnum4
    autoconf
    automake
    cmake

    # debug
    gdb
    strace
    ltrace
    patchelf
    inotify-tools
    universal-ctags

    bpftrace
    bpftools
    bcc

    # doc
    man-pages
    man-pages-posix
    linux-manual

    # sec
    gnupg
    cryptsetup
    thc-secure-delete

    # net
    nmap
    sshfs
    openssh
    tcpdump

    # tor
    tor
    torsocks
    tor-browser

    # virt
    qemu
    docker
    docker-buildx
    docker-client

    # ascii
    sl
    sl2
    figlet
    toilet
    cowsay
    xcowsay
    cmatrix
    neofetch
    asciiquarium

    # tty
    vim_configurable
    ranger
    tmux

    # mid-level
    xorg.xinit
    xorg.xeyes
    xorg.xhost
    xclip
    xdotool
    imagemagick

    # phone
    adbfs-rootless
    android-udev-rules

    # desktop
    eog
    meld
    gimp
    ghex
    gedit
    conky
    evince
    vscode
    baobab
    dropbox
    gparted
    obsidian
    google-chrome
    gnome-terminal
    github-desktop
    ffmpegthumbnailer

    # themes
    numix-gtk-theme
    numix-icon-theme-circle

    # video
    vlc
    ffmpeg
    kdePackages.kdenlive
    simplescreenrecorder

    # social
    wechat
    whatsapp-for-linux

    # games
    stepmania

    # mathematics
    lean4

    # nix
    nix-bash-completions
    nix-prefetch-github
    home-manager
    dconf2nix

    # work
    glab
    awscli2
    teams-for-linux
    gitlab-ci-local
    gitlab-container-registry
    (aws-cvpn-client.packages.${system}.default)

    # ports
    weatherspect
    (pkgs.perl.withPackages (ps: with ps; [
      TermAnimation
      JSON
      LWP
    ]))

    # compiling python upstream
    pkg-config
    gcc.cc.lib
    zlib
    zlib.dev
    openssl
    openssl.dev
    bzip2
    bzip2.dev
    xz
    xz.dev
    zstd
    zstd.dev
    libffi
    libffi.dev
    readline
    readline.dev
    ncurses
    ncurses.dev
    gdbm
    gdbm.dev
    sqlite
    sqlite.dev
    libuuid
    libuuid.dev
    tk
    tk.dev
    tcl

    # cpython HEAD!
    # python-head

    # raw derivations
    sayhi   # stdenv.mkDerivation, depends on hi
    saybye  # builtins.derivation, depends on raw bye

    # raw binary machine code overlay ftw
    noelf

    (python313.withPackages (ps: with ps; (python_large ps) ++ [

      scikit-learn
      torch

      embd
      wnix

    ]))

    (python313FreeThreading.withPackages (ps: with ps; [
      ipython
    ]))

    (python314.withPackages (ps: with ps; [
      ipython
    ]))

    (python314FreeThreading.withPackages (ps: with ps; [
      ipython
    ]))

    (python315.withPackages (ps: with ps; [
      ipython
    ]))

    (python315FreeThreading.withPackages (ps: with ps; [
    ]))

  ];

  boot.kernel.sysctl = {
    "net.core.bpf_jit_enable" = 1;
    "kernel.unprivileged_bpf_disabled" = 0; # set to 0 if you want unprivileged bpf
  };

  # android debug bridge
  programs.adb.enable = true;

  # dconf
  programs.dconf.enable = true;

  # this i guess...
  virtualisation.docker.enable = true;

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
