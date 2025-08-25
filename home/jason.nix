{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

  src = import ./src.nix;
  inherit (src) nix exec personal;
  inherit (src) secret legacy;

  link = config.lib.file.mkOutOfStoreSymlink;

in {

  home.username = user;
  home.homeDirectory = "/home/${user}";
  news.display = "silent";

  # ~/.config/git
  programs.git = {
    enable    = true;
    userName  = name;
    userEmail = email;
    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
    };
  };

  # ~/.config/gh
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };


  home.packages = with pkgs; [
    git
    dconf
    inotify-tools
    numix-gtk-theme
    numix-icon-theme-circle
  ];

  gtk = with pkgs; {
    enable = true;
    theme = { name = "Numix"; package = numix-gtk-theme; };
    iconTheme = { name = "Numix-Circle"; package = numix-icon-theme-circle; };
  };

  home.file = lib.mkMerge [{

    # ~/.local/share/icons
    ".local/share/icons/Numix-Circle/scalable/apps/obsidian.png".source = ./icons/obsidian.png;

    # ~/.local/share/applications
    ".local/share/applications/obsidian.desktop".text =
        let
          src = builtins.readFile "${pkgs.obsidian}/share/applications/obsidian.desktop";
          icon = "${config.home.homeDirectory}/.local/share/icons/Numix-Circle/scalable/apps/obsidian.png";
        in
          builtins.replaceStrings ["Icon=obsidian"] ["Icon=${icon}"] src;
  }];

  home.activation = {

    setupDconf = lib.hm.dag.entryAfter ["installPackages"] ''
      export PATH="${config.home.path}/bin:${pkgs.glib}/bin:$PATH"
      "${personal.dst}/bin/setup-dconf"
    '';

    setupCinnamon = lib.hm.dag.entryAfter ["setupDconf"] ''
      export PATH="${pkgs.python3}/bin:${pkgs.inotify-tools}/bin:$PATH"

      # inotify can't watch paths that don't exist yet, so mkdir this
      dir="$HOME/.config/cinnamon/spices/panel-launchers@cinnamon.org"
      mkdir -pv "$dir"
      if [[ $(ls "$dir" | wc -l) < 1 ]]; then
        echo "Waiting for cinnamon to create panel-launchers."
        inotifywait -qr -t 5 "$dir" || { echo Waiting for cinnamon timed out; } &&
        echo "Panel launchers created, setting up cinnamon."
      fi
      "${personal.dst}/bin/setup-cinnamon"
    '';

  };

  # git clone public repos
  home.activation.clonePublic = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

    export PATH="${pkgs.git}/bin:$PATH"

    if [ ! -d "${nix.dst}" ]; then
      git clone "${nix.src}" "${nix.dst}"
    fi

    if [ ! -d "${exec.dst}" ]; then
      git clone "${exec.src}" "${exec.dst}"
    fi

    if [ ! -d "${personal.dst}" ]; then
      git clone "${personal.src}" "${personal.dst}"
    fi
  '';

  home.file = lib.mkMerge [{

    # symlinks from exec
    ".vimrc".source     = link "${exec.dst}/etc/vimrc";
    ".face".source      = link "${exec.dst}/etc/dot-face";

    # ipython startup file
    ".ipython/profile_default/startup/00-pyrc.py".source = link "${exec.dst}/bin/pyrc";

    # symlinks from personal
    "Templates".source  = link "${personal.dst}/etc/Templates";

    # auto-generated
    ".hotdogrc".text    = ''This is not a config file'';

  }];

  # PATH for interactive shells
  # home.sessionVariables.PATH = lib.mkBefore "${exec.dst}/bin:${personal.dst}/bin";


  # PATH for login shells
  home.sessionPath = [
    "${exec.dst}/bin"
    "${personal.dst}/bin"
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${exec.dst}/etc/bashrc"
      source "${personal.dst}/etc/bashrc"
    '';
  };

  home.packages = with pkgs; [
    git
    dconf
    inotify-tools
  ];

  xdg.configFile = {

    # ~/.config/autostart/conky.desktop
    "autostart/conky.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Conky
        Exec=${personal.dst}/conky-smart-start
        X-GNOME-Autostart-enabled=true
        NoDisplay=false
        Comment=Start Conky at login
      '';
    };
  };

  # git clone private repos
  home.activation.clonePrivate = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

    export PATH="${pkgs.git}/bin:$PATH"

    if [ ! -d "${secret.dst}" ]; then
      git clone "${secret.src}" "${secret.dst}"
    fi

    if [ ! -d "${legacy.dst}" ]; then
      git clone "${legacy.src}" "${legacy.dst}"
    fi

  '';

  home.file = lib.mkMerge [{
    # sooper serious secrets zomg
    ".pypirc".source    = link "${secret.dst}/etc/pypirc";
    ".netrc".source     = link "${secret.dst}/etc/netrc";
    ".ssh".source       = link "${secret.dst}/etc/ssh";

    # gitlab
    ".config/glab-cli/config.yml".source = link "${secret.dst}/etc/glab-cli-config.yml";
  }];

  # PATH for interactive shells
  # home.sessionVariables.PATH = lib.mkBefore "${secret.dst}/bin";

  # PATH for login shells
  home.sessionPath = [
    "${secret.dst}/bin"
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = lib.mkAfter ''
      source "${secret.dst}/etc/bashrc"
    '';
  };
  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  # Don't delete this
  home.stateVersion = "25.05";
}
