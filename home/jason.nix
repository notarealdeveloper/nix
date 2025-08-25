{ pkgs, lib, config, desktop ? true, private ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

  src = import ./src.nix { inherit config; };
  inherit (src) nix exec personal overlay;
  inherit (src) secret legacy;

  link = config.lib.file.mkOutOfStoreSymlink;

in {

  home.username = user;
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


  # Base packages
  home.packages = with pkgs; [
    git
  ] ++ lib.optionals desktop [
    dconf
    inotify-tools
    numix-gtk-theme
    numix-icon-theme-circle
  ];

  # Desktop theming (conditional)
  gtk = lib.mkIf desktop (with pkgs; {
    enable = true;
    theme = { name = "Numix"; package = numix-gtk-theme; };
    iconTheme = { name = "Numix-Circle"; package = numix-icon-theme-circle; };
  });

  home.activation = {

    # git clone public repos
    clonePublic = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

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

      if [ ! -d "${overlay.dst}" ]; then
        git clone "${overlay.src}" "${overlay.dst}"
      fi
    '';

    # git clone private repos (conditional)
    clonePrivate = lib.mkIf private (lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

      export PATH="${pkgs.git}/bin:$PATH"

      if [ ! -d "${secret.dst}" ]; then
        git clone "${secret.src}" "${secret.dst}"
      fi

      if [ ! -d "${legacy.dst}" ]; then
        git clone "${legacy.src}" "${legacy.dst}"
      fi

    '');

    # desktop setup
    setupDconf = lib.mkIf desktop (lib.hm.dag.entryAfter ["installPackages"] ''
      export PATH="${pkgs.glib}/bin:$PATH"
      "${personal.dst}/bin/setup-dconf"
    '');

    setupCinnamon = lib.mkIf desktop (lib.hm.dag.entryAfter ["setupDconf"] ''
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
    '');

  };

  home.file = lib.mkMerge [
    {
      # symlinks from exec
      ".vimrc".source     = link "${exec.dst}/etc/vimrc";
      ".face".source      = link "${exec.dst}/etc/dot-face";

      # ipython startup file
      ".ipython/profile_default/startup/00-pyrc.py".source = link "${exec.dst}/bin/pyrc";

      # symlinks from personal
      "Templates".source  = link "${personal.dst}/etc/Templates";

      # auto-generated
      ".hotdogrc".text    = ''This is not a config file'';
    }

    # Desktop-specific files (conditional)
    (lib.mkIf desktop {
      # ~/.local/share/icons
      ".local/share/icons/Numix-Circle/scalable/apps/obsidian.png".source = ./icons/obsidian.png;

      # ~/.local/share/applications
      ".local/share/applications/obsidian.desktop".text =
          let
            src = builtins.readFile "${pkgs.obsidian}/share/applications/obsidian.desktop";
            icon = ".local/share/icons/Numix-Circle/scalable/apps/obsidian.png";
          in
            builtins.replaceStrings ["Icon=obsidian"] ["Icon=${icon}"] src;
    })

    # Private files (conditional)
    (lib.mkIf private {
      # sooper serious secrets zomg
      ".pypirc".source    = link "${secret.dst}/etc/pypirc";
      ".netrc".source     = link "${secret.dst}/etc/netrc";
      ".ssh".source       = link "${secret.dst}/etc/ssh";

      # gitlab
      ".config/glab-cli/config.yml".source = link "${secret.dst}/etc/glab-cli-config.yml";
    })
  ];

  # PATH for login shells (consolidated with conditional private paths)
  home.sessionPath = [
    "${exec.dst}/bin"
    "${personal.dst}/bin"
  ] ++ lib.optionals private [
    "${secret.dst}/bin"
  ];

  # Bash configuration (consolidated with conditional private sources)
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${exec.dst}/etc/bashrc"
      source "${personal.dst}/etc/bashrc"
    '' + lib.optionalString private ''
      source "${secret.dst}/etc/bashrc"
    '';
  };

  # Desktop autostart configuration (conditional)
  xdg.configFile = lib.mkIf desktop {
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
  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  # Don't delete this
  home.stateVersion = "25.05";
}
