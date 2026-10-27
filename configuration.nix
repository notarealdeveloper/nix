#########################
### configuration.nix ###
#########################

{ pkgs, lib, config, ... }:

let

  # for help, see nixos-help or man nix.conf

  cacheName = "notarealdeveloper";

  pythonWithPackages = python: python.withPackages (ps: with ps; [
    pip
    build
    pytest
    setuptools
    cython
    twine

    ipython
    sly
    curio

    requests
    beautifulsoup4
    selenium
    yt-dlp

    numpy
    sympy
    editdistance
    scipy
    pandas
    matplotlib
    pycairo
    pyqt6
    seaborn
    scikit-learn
    h5py
    pillow
    lz4

    google-auth-oauthlib
    google-api-python-client
    geoip2
  ]);

  pythonWithoutPackages = python: python.withPackages (ps: with ps; [
    pip
    build
    pytest
    setuptools
    requests
    ipython
  ]);

  python313 = pythonWithPackages pkgs.python313;
  python314 = pythonWithPackages pkgs.python314;
  python314FreeThreading = pythonWithPackages pkgs.python314FreeThreading;
  #python315FreeThreading = pythonWithPackages pkgs.python315FreeThreading;

  bookFontPackages = with pkgs; [
    noto-fonts                  # hebrew, telugu, arabic, egypt, phoenician, imperial aramaic
    noto-fonts-cjk-sans         # chinese, japanese, korean
    noto-fonts-cjk-serif        # ibid
    noto-fonts-color-emoji      # obviously
    source-han-serif            # ibid
    culmus                      # hebrew
    unifont                     # i forget
    google-fonts                # ibid
    wqy_zenhei                  # cjk
    arphic-ukai                 # cjk
    arphic-uming                # cjk
    babelstone-han              # cjk
    dejavu_fonts                # standard
    liberation_ttf              # reasonable
    #roboto                     # DON'T UNCOMMENT THIS, IT FUCKS UP LIGHTDM
  ];

in

{

  imports = [ ./configuration-stage-one.nix ];

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      libpinyin
      anthy
      hangul
    ];
  };

  # cups
  services.printing.enable = true;

  # intune for work
  # services.intune.enable = true;

  # system
  environment.systemPackages =

    with pkgs; [


    # python
    (lib.hiPrio python314) # prefer the full environment over the bootstrap Python
    python315FreeThreading
    python313
    uv

    # unix
    pcre
    acpi
    plocate
    git-filter-repo # tbrncl

    # mail
    msmtp
    mailutils

    # formats
    cpio
    pigz
    qpdf # for zlib-flate
    dos2unix

    # build
    nasm
    bison
    clang
    meson
    ccache
    gnum4
    autoconf
    automake
    cmake
    #cachix

    # debug
    iw
    gdb
    xev
    iotop
    strace
    ltrace
    ethtool
    binwalk
    powertop
    patchelf
    nvme-cli
    dmidecode
    tesseract
    aircrack-ng
    universal-ctags
    witr # witr = why is this running
    busybox

    pinentry-tty
    pinentry-curses

    # matplotlib agg non-interactive bullshit
    cairo
    mesa
    libglvnd
    qt6.qtbase

    # satan
    system-config-printer

    # x11 libs
    libX11
    libXext
    libXrender
    libXrandr
    libxcb
    libxkbcommon
    xcbutil
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
    xinit
    xeyes
    xhost
    libX11
    libxcb
    libXau
    libXdmcp
    libXext
    libXrender

    #bpftrace
    #bpftools
    #bcc

    # doc
    man-pages-posix

    # sec
    foremost
    thc-secure-delete

    # net
    nmap
    sshfs
    openvpn
    tcpdump
    arp-scan
    net-tools
    expressvpn
    mullvad
    #aws-cvpn   # I WANT THIS BUT BUILD EEZ BROKE

    # tor
    tor
    torsocks
    tor-browser

    # virt
    qemu
    docker
    docker-buildx
    docker-client

    # fun
    sl
    sl2
    figlet
    toilet
    xcowsay
    cmatrix
    fastfetch
    asciiquarium
    espeak
    espeak-ng

    # tty
    ghostty
    bat
    highlight
    glow
    rlwrap

    # tty image previews in ranger
    ueberzugpp    # works
    w3m           # doesn't seem to
    enlightenment.terminology
    lsix

    # mid-level
    glib
    zlib
    stdenv.cc.cc.lib   # provides libstdc++.so.6 which wheels often need
    imagemagick
    netpbm
    freetype
    glib
    dbus
    sqlcipher
    openai-whisper

    # fonts for the book
  ] ++ bookFontPackages ++ [
    pango                       # παν語
    pandoc                      # obviously
    fontconfig                  # ibid
    fontforge-gtk               # ibid
    font-manager                # editing fonts

    # the book
    lua
    texmaker
    texlab
    texliveFull
    ghostscript
    epubcheck
    foliate
    #calibre
    wineWow64Packages.stable
    winetricks

    # codex
    chatgpt-cli
    bubblewrap
    ruby

    # phone
    adbfs-rootless
    androidenv.androidPkgs.platform-tools
    avahi
    scrcpy
    better-adb-sync

    # desktop
    eog
    glib.dev
    qview
    geeqie
    meld
    gimp
    ghex
    gedit
    pinta
    conky
    guake
    mupdf
    evince
    baobab
    nushell
    firefox
    dropbox
    gparted
    parallel
    vbindiff
    lazpaint
    inkscape
    obsidian
    xournalpp
    zed-editor
    geckodriver
    chromedriver
    poppler-utils
    github-desktop
    transmission_4-gtk
    ffmpegthumbnailer
    libreoffice-stable

    # editors
    vscode
    zed-editor-fhs
    zod

    # ibus
    ibus
    ibus-engines.anthy
    ibus-engines.libpinyin
    ibus-engines.hangul
    ibus-engines.pinyin
    #ibus-engines.mozc

    # themes
    mint-themes
    numix-icon-theme-circle

    # video
    vlc
    ffmpeg-full
    kdePackages.kdenlive
    simplescreenrecorder
    rnnoise-plugin

    # social
    wechat
    karere # whatsapp client like wasistlos
    zoom-us
    discord
    slack

    # games
    # stepmania

    # nix
    nix-bash-completions
    nix-prefetch-github
    dconf2nix

    # work
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

    # for sudocode
    bc        # In the beginning
    gfortran  # Fortran. (1957). John Backus and his team at IBM.
    gnucobol  # Cobol. (1959). Designed by the CODASYL committee, partly based on Grace Hopper's FLOW-MATIC language.
    clisp     # Lisp. (1956 to 1960). John McCarthy developed the basics during a summer AI research project.
    guile     # Scheme. (1975). Guy Steele and Gerald Sussman, the "Lambda the Ultimate" papers.
    rustc     # Rust. (2006 to 2015). Graydon Hoare created Rust in 2006, Mozilla sponsored it in 2009. Released 2012. Stable 2015.
    ghc       # Haskell
    idris     # Dependent types
    idris2    # Dependenter types
    exiftool
    #lean4    # The Highest

    # remote lord access
    tailscale

  ];

  fonts = {

    packages = bookFontPackages;

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Noto Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

  };
  services.tor.enable = true;
  services.tor.client.enable = true;

  # for adb over wifi
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  #boot.kernel.sysctl = {
  #  "net.core.bpf_jit_enable" = 1;
  #  "kernel.unprivileged_bpf_disabled" = 0; # set to 0 if you want unprivileged bpf
  #};

  xdg = {
    menus.enable = true;
    mime.enable = true;
    icons.enable = true;
  };

  environment.etc."sendmail".source = "${pkgs.msmtp}/bin/msmtp";
  environment.variables.SENDMAIL = "${pkgs.msmtp}/bin/msmtp";

  programs.msmtp = {
    enable = true;
    setSendmail = true;

    accounts = {
      default = {
        host = "smtp.gmail.com";
        port = 587;

        auth = true;
        tls = true;
        tls_starttls = true;
        tls_trust_file = "/etc/ssl/certs/ca-bundle.crt";

        user = "letshaveanadventure@gmail.com";
        from = "letshaveanadventure@gmail.com";
        passwordeval = "cat /home/jason/.auth-is-serious-guys-cmon";
      };
    };
  };

  # os virtualization
  virtualisation.docker.enable = true;

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
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  programs.openvpn3.enable = true;
  services.expressvpn.enable = true;

  users.users.luna.packages = with pkgs; [ yt-dlp vlc ];

  programs.fuse.userAllowOther = true;

  networking.hosts = {
    #"167.172.219.109" = [ "fukkot" ];
  };
}
