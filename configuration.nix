{ pkgs, lib, config, doubleunix, ... }:

let

  # for help, see nixos-help or man nix.conf

  # wnixpkgs = builtins.attrValues doubleunix.packages.${pkgs.stdenv.hostPlatform.system};

  wnixpkgs = doubleunix.packages.${pkgs.stdenv.hostPlatform.system};

  cacheName = "notarealdeveloper";

  all = (ps: with ps; [

    # packaging
    pip
    build
    pytest
    setuptools
    cython

    # basics
    ipython
    #sly
    #curio

    # net
    requests
    beautifulsoup4

    # numerical
    numpy
    sympy
    editdistance

    # ours
    #assure
    #is-instance
    #python-bin
    #mmry
    #webfs

  ]);

  std = (ps: with ps; [
    # packaging
    twine

    # net
    yt-dlp

    # numerical
    scipy
    pandas
    matplotlib
    pyqt6

    seaborn
    scikit-learn
    #lambda-multiprocessing
    #lightgbm
    h5py
    pillow

    # ~/bin depends
    google-auth-oauthlib      # gmail
    google-api-python-client  # gmail, getbtcprice
    geoip2                    # getbtcprice

    # for sklearn
    lz4
  ]);

in

{

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

  i18n.inputMethod = {
    type = "ibus";
    enable = true;
    ibus.engines = with pkgs.ibus-engines; [
      anthy          # Japanese
      libpinyin      # Chinese
      hangul         # Korean
    ];
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

  # cups
  services.printing.enable = true;

  # sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # intune for work
  # services.intune.enable = true;

  # system
  environment.systemPackages =

    with pkgs; [


    #(python313.withPackages (ps: all ps ++ std ps))
    #(python311.withPackages (ps: all ps ++ std ps))

    # pythons, from the overlay
    wnixpkgs.py313 # first gets priority
    wnixpkgs.py311
    #wnixpkgs.py312
    #wnixpkgs.py313t
    #wnixpkgs.py314t
    #wnixpkgs.py315
    #wnixpkgs.py315t

    # unix
    gh
    git
    wget
    tree
    pcre
    acpi
    plocate

    # mail
    mailutils

    # formats
    jq
    file
    cpio
    pigz
    unzip
    dos2unix

    # build
    gcc
    nasm
    bison
    clang
    meson
    ccache
    cachix
    gnumake
    gnum4
    autoconf
    automake
    cmake

    # debug
    gdb
    xev
    strace
    ltrace
    patchelf
    inotify-tools
    universal-ctags
    witr # witr = why is this running

    pinentry-tty
    pinentry-curses
    pinentry-gnome3

    # matplotlib agg non-interactive bullshit
    mesa
    libglvnd
    qt6.qtbase

    #bpftrace
    #bpftools
    #bcc

    # doc
    man-pages
    man-pages-posix
    linux-manual

    # sec
    gnupg
    foremost
    cryptsetup
    #thc-secure-delete

    # net
    nmap
    sshfs
    openssh
    tcpdump
    net-tools

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
    vim-full
    ranger
    tmux
    espeak
    espeak-ng

    # mid-level
    xorg.xinit
    xorg.xeyes
    xorg.xhost
    xclip
    xdotool
    imagemagick

    # fonts
    noto-fonts            # hebrew, telugu, devangari, arabic, egyptian hiero, phoenician
    noto-fonts-cjk-sans   # chinese, japanese, korean
    noto-fonts-cjk-serif  # cjk
    source-han-serif      # ibid
    culmus                # hebrew
    unifont               # i forget
    google-fonts

    # phone
    android-tools
    adbfs-rootless

    # desktop
    eog
    meld
    gimp
    ghex
    gedit
    pinta
    conky
    guake
    evince
    vscode
    baobab
    dropbox
    gparted
    lazpaint
    inkscape
    obsidian
    xournalpp
    poppler-utils
    google-chrome
    gnome-terminal
    github-desktop
    ffmpegthumbnailer
    libreoffice-fresh

    # ibus
    ibus
    ibus-engines.anthy
    ibus-engines.libpinyin
    ibus-engines.hangul
    libpinyin

    # themes
    numix-gtk-theme
    numix-icon-theme-circle

    # video
    vlc
    ffmpeg-full
    #kdePackages.kdenlive
    simplescreenrecorder
    rnnoise-plugin

    # social
    wechat
    wasistlos
    zoom-us

    # games
    # stepmania

    # nix
    nix-bash-completions
    nix-prefetch-github
    home-manager
    dconf2nix

    # work
    nodePackages.nodejs
    nodePackages.npm
    glab
    awscli2
    teams-for-linux
    gitlab-ci-local
    gitlab-container-registry
    # intune-portal

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
    p7zip
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

    # for fuse google drive mount
    rclone
    fuse3

    # tensorflow
    bazel
    bazelisk

    # raw derivations
    #sayhi   # stdenv.mkDerivation, depends on hi
    #saybye  # builtins.derivation, depends on raw bye

    # raw binary machine code overlay ftw
    noelf

    # tex
    texmaker
    texliveFull
    ghostscript

    # for the book
    bc        # In the beginning
    gfortran  # Fortran. (1957). John Backus and his team at IBM.
    #gnucobol  # Cobol. (1959). Designed by the CODASYL committee, partly based on Grace Hopper's FLOW-MATIC language.
    clisp     # Lisp. (1956 to 1960). John McCarthy developed the basics during a summer AI research project.
    guile     # Scheme. (1975). Guy Steele and Gerald Sussman, the "Lambda the Ultimate" papers.
    rustc     # Rust. (2006 to 2015). Graydon Hoare created Rust in 2006, Mozilla sponsored it in 2009. Released 2012. Stable 2015.
    ghc       # Haskell
    idris     # Dependent types
    idris2    # Dependenter types
    lean4     # The Highest
    fontforge # Proto-Sinaitic font debugging
    pango     # παν語
    exiftool
    pandoc


  ]; # ++ wnixpkgs;

  #boot.kernel.sysctl = {
  #  "net.core.bpf_jit_enable" = 1;
  #  "kernel.unprivileged_bpf_disabled" = 0; # set to 0 if you want unprivileged bpf
  #};

  programs.msmtp = {
    enable = true;

    # A minimal, practical setup (example uses Gmail SMTP; adjust for your provider)
    accounts = {
      defaults = {
        tls = true;
        tls_starttls = true;
        tls_trust_file = "/etc/ssl/certs/ca-bundle.crt";
        auth = true;
      };

    accounts.default = {
      host = "smtp.gmail.com";
      port = 587;

      # Your email identity
      from = "root@thedynamiclinker.com";
      user = "root@thedynamiclinker.com";

      # Prefer using a secret manager; for quick tests you can inline temporarily:
      passwordeval = "cat /home/jason/.auth-is-serious-guys-cmon";
    };

  };

  # login keyring
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;      # harmless if you don't use gdm
  security.pam.services.lightdm.enableGnomeKeyring = true;  # harmless if you don't use lightdm

  # this combination seems to work best
  services.gnome.gcr-ssh-agent.enable = true;   # keyring for ssh keys
  services.gnome.gnome-keyring.enable = true;   # keyring for browser/passwords

  #services.openssh = {
  #  enable = true;
  #  settings = {
  #    PasswordAuthentication = true;
  #    PermitRootLogin = "no";
  #  };
  #};

  hardware.graphics.enable = true;

  # dconf
  programs.dconf.enable = true;

  # os virtualization
  virtualisation.docker.enable = true;

  # i forget what this is for
  gtk.iconCache.enable = false;

  # vim: clipboard support
  programs.vim = {
    enable = true;
    package = pkgs.vim-full;  # this is the default full-featured vim with +clipboard
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
  #networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  #programs.openvpn3.enable = true;

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
      yt-dlp
      vlc
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
      email = root@thedynamiclinker.com
    [init]
      defaultBranch = master
    [pull]
      rebase = true
    [commit]
      verbose = true
  '';


  ################
  ### <cachix> ###
  ################

  nix.settings = {

    trusted-users = [ "root" "user" "jason" ];

    substituters = [
      "https://cache.nixos.org"
      "https://${cacheName}.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "${cacheName}.cachix.org-1:lTWU+5FB7gvLg39/9EY1GDE3JV4HkRtprgxuKmkm/7g="
    ];

    post-build-hook = pkgs.writeShellScript "post-build-cachix.sh" ''
      set -euo pipefail
      # Nix sets OUT_PATHS as a space-separated list.
      # Send them to the daemon (fast, non-blocking wrt builds).
      if [ -n "''${OUT_PATHS-}" ]; then
        ${pkgs.cachix}/bin/cachix daemon push $OUT_PATHS || true
      fi
    '';

  };

  systemd.tmpfiles.rules = [ "d /etc/cachix 0750 root root -" ];

  systemd.services = {

    "cachix-daemon@${cacheName}" = {

      description = "Cachix daemon for ${cacheName}";

      wantedBy = [ "multi-user.target" ];

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        EnvironmentFile = "/etc/cachix/${cacheName}.env";
        ExecStart = "${pkgs.cachix}/bin/cachix daemon run ${cacheName}";

        Restart = "always";
        RestartSec = "10s";
      };

      # prevent "Start request repeated too quickly"
      startLimitIntervalSec = 0;  # disable rate limiting
    };

  };

  #################
  ### </cachix> ###
  #################

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  programs.fuse.userAllowOther = true;

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
