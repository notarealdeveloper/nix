{ pkgs, lib, config, doubleunix, ... }:

let

  # for help, see nixos-help or man nix.conf

  wnixpkgs = builtins.attrValues doubleunix.packages.${pkgs.stdenv.hostPlatform.system};

  cacheName = "notarealdeveloper";

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

  # system
  environment.systemPackages =

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

    # fonts
    noto-fonts          # hebrew, telugu, devangari, arabic
    noto-fonts-cjk-sans # chinese, japanese, korean
    noto-fonts-extra    # egyptian hieroglyphs, phoenician

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
    libreoffice-fresh

    # ibus
    ibus
    ibus-engines.anthy
    ibus-engines.libpinyin
    ibus-engines.hangul

    # themes
    numix-gtk-theme
    numix-icon-theme-circle

    # video
    vlc
    ffmpeg
    kdePackages.kdenlive
    simplescreenrecorder

    # social
    # wechat
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

    # tensorflow
    bazel
    bazelisk

    # raw derivations
    sayhi   # stdenv.mkDerivation, depends on hi
    saybye  # builtins.derivation, depends on raw bye

    # raw binary machine code overlay ftw
    noelf

  ] ++ wnixpkgs;

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
      serviceConfig = {
        Type = "simple";
        # Reads env file with CACHIX_AUTH_TOKEN
        EnvironmentFile = "/etc/cachix/${cacheName}.env";
        ExecStart = "${pkgs.cachix}/bin/cachix daemon run ${cacheName}";
        Restart = "on-failure";
        Environment = "NIX_SHOW_STATS=1";
      };

    };

  };

  #################
  ### </cachix> ###
  #################

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # bluetooth
  hardware.bluetooth = {
    enable = true;  # loads btusb
    powerOnBoot = true;
    # Turn off BlueZ privacy if the adapter throws 0x03 errors
    settings = { General = { Privacy = "off"; }; };
  };

  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

}
