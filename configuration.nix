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
    neovim
    file
    wget
    tree
    unzip
    plocate
    git
    gh
    zlib
    glab
    jq
    acpi
    tmux

    # dev
    gcc
    gnumake
    ranger
    adbfs-rootless
    android-udev-rules

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
    xorg.xhost
    xclip
    xdotool
    imagemagick
    sshfs
    nasm

    # sec
    gnupg
    tor
    torsocks
    tor-browser
    cryptsetup
    thc-secure-delete

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
    gparted
    baobab
    ghex

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

    # mathematics
    lean4

    (python.withPackages (ps: with ps; [

      # packaging
      pip
      build
      twine
      pytest
      setuptools
      cython

      # basics
      ipython

      # net
      requests
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

      # derivations
      jello

      # overlay
      is_instance
      python-bin
      embd
      wnix

    ]))

    # work
    (python311.withPackages (ps: with ps; [ pip ]))
    awscli2
    gitlab-ci-local
    gitlab-container-registry
    git-lfs

    # software and hardware virtualisation
    qemu
    docker
    docker-buildx
    docker-client

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

    # rust
    rustc
    cargo

    # haskell
    ghc
    cabal-install

    # window managers
    awesome
    xmonad-with-packages

    # <ABOMINATIONS>
    ##
    ## Hi there!
    ##
    ## Welcome to the abominations section.
    ##
    ## In this section we install packages
    ## that happen also to be crimes against
    ## humanity, morality, and whatever set
    ## of gods (possibly empty) might happen
    ## to exist. First abomination on the list...
    ##
    ## conda!
    ##
    ## Ok this one's actually kinda cute,
    ## despite also being a total abortion.
    ##
    ## This little guy (1) installs X11 when
    ## you install numpy, (2) downgrades
    ## your python version in non-commutative
    ## ways, and (3) modifies /proc/self/root
    ## such that you see a different set of
    ## directories when you `ls /`, and does
    ## so without requiring root! The final
    ## part isn't necessarily mysterious or
    ## whatever. It's clearly just some simple
    ## call to `unshare` or something, but in
    ## practice it's equivalent to a sizable
    ## subset of docker, and it got there by
    ## wanting to install numpy and other stuff
    ## in a way that's consistent with whatever
    ## silly overfit shit is hard-coded in your
    ## company's 79 year old requirements.txt
    ## Ladies and gentlemen give a big round of
    ## applause to...
    conda
    ## Haha what a weird little guy conda is...
    ## Almost cute though, if you squint.
    ## Ok what's next?
    ## (Narrator: The host's eyes widen in terror)
    ## Oh jesus
    ## Oh fuck
    ## Um wow ok.
    ## Holy my beer
    ## 
    ##  ☢️  ☢️  ☢️  ☢️
    ## <QUARANTINE>
    ### > But He turned and said unto Ptr
    ### > "Get thee behind Me, Satan!
    ### > Thou art an offense unto Me;
    ### > for thou savorest not the things
    ### > that be of /bin, but those that be of
    ### > /home/user/.cache/pypoetry/virtualenvs/repo-UJ6YPHE3-py3.13/bin
    ### > -Jesus fucking Christ
    ### >  Matthew 16:23
    ### >  Paraphrased
    #############
    ###############                   # (Narrator: The inverse funnel on the left is
    #################                 #  a common mechanism found in devices like crab
                        poetry        #  traps to make sure the little bastard can't
    #################                 #  figure out how to escape out into the
    ###############     # ^ ew gross  #  rest of the package list.)
    #############
    ### Don't touch me poetry.
    ### I'm just using you in a
    ### book as part of a joke.
    ##
    ## </QUARANTINE>
    ##  ☢️  ☢️  ☢️  ☢️
    ##
    # </ABOMINATIONS>

    # experiments
    python314FreeThreading
    # python311submissive
    # python-head

    # raw derivations
    sayhi   # stdenv.mkDerivation, depends on hi
    saybye  # builtins.derivation, depends on raw bye
    yello   # attempt to declare an importable that depends on an executable

    # raw binary machine code overlay ftw
    LD
    LD-mkdir
    LD-rmdir
  ];

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
