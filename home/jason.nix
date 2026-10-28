######################
### home/jason.nix ###
######################

{ pkgs
, lib
, config
, desktop ? true
, private ? true
, ...
}:

let
  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

  src = import ./src.nix { inherit config; };
  inherit (src) nix exec personal;
  inherit (src) secret legacy;

  link = config.lib.file.mkOutOfStoreSymlink;

  setupDconf = pkgs.writeShellScript "setup-dconf" ''
    set -euo pipefail
    export PATH="${config.home.path}/bin:${pkgs.dconf}/bin:${pkgs.glib}/bin:$PATH"
    "${personal.dst}/bin/setup-dconf"
    # The personal script still selects Numix, which we no longer install.
    # Keep Cinnamon and GNOME consistent with the theme managed below.
    dconf load / <<EOF
    [org/cinnamon/desktop/interface]
    gtk-theme='${config.gtk.theme.name}'
    icon-theme='${config.gtk.iconTheme.name}'
    [org/gnome/desktop/interface]
    gtk-theme='${config.gtk.theme.name}'
    icon-theme='${config.gtk.iconTheme.name}'
    EOF
  '';

  # Cinnamon creates these files during its first login, after NixOS activation.
  setupCinnamon = pkgs.writeShellScript "setup-cinnamon" ''
    export PATH="${pkgs.python3}/bin:${pkgs.coreutils}/bin:$PATH"
    for attempt in $(seq 1 30); do
      ready=true
      for file in \
        menu@cinnamon.org/0.json \
        calendar@cinnamon.org/13.json \
        panel-launchers@cinnamon.org/15.json \
        power@cinnamon.org/power@cinnamon.org.json; do
        if [ ! -f "$HOME/.config/cinnamon/spices/$file" ]; then
          ready=false
        fi
      done
      if [ "$ready" = true ]; then
        exec "${personal.dst}/bin/setup-cinnamon"
      fi
      if [ "''${1:-}" != --wait ]; then break; fi
      sleep 1
    done
    echo "Cinnamon settings deferred until its applet files exist (next login or rebuild)."
  '';

  notoSansFallbacks = [
    "Noto Sans Hebrew"
    "Noto Sans Arabic"
    "Noto Sans Syriac"
    "Noto Sans Samaritan"
    "Noto Sans Mandaic"

    "Noto Sans Phoenician"
    "Noto Sans Imperial Aramaic"
    "Noto Sans Nabataean"
    "Noto Sans Palmyrene"
    "Noto Sans Hatran"
    "Noto Sans Old North Arabian"
    "Noto Sans Old South Arabian"
    "Noto Sans Ugaritic"

    "Noto Sans Old Persian"
    "Noto Sans Avestan"
    "Noto Sans Inscriptional Pahlavi"
    "Noto Sans Inscriptional Parthian"
    "Noto Sans Psalter Pahlavi"
    "Noto Sans Manichaean"

    "Noto Sans Old Italic"
    "Noto Sans Gothic"
    "Noto Sans Runic"
    "Noto Sans Coptic"

    "Noto Sans Linear A"
    "Noto Sans Linear B"
    "Noto Sans Cypriot"
    "Noto Sans Cypro Minoan"

    "Noto Sans Cuneiform"
    "Noto Sans Egyptian Hieroglyphs"
    "Noto Sans Anatolian Hieroglyphs"

    "Noto Sans Symbols"
    "Noto Sans Symbols 2"
    "Noto Color Emoji"
  ];

  notoSerifFallbacks = [
    "Noto Serif Hebrew"
    "Noto Serif Georgian"
    "Noto Serif Tibetan"
    "Noto Serif Old Uyghur"
  ] ++ notoSansFallbacks;

  xmlFamilies = families:
    lib.concatMapStringsSep "\n"
      (f: "            <family>${f}</family>")
      families;

in {

  home.username = user;
  home.homeDirectory = "/home/${user}";
  news.display = "silent";

  # ~/.config/git
  programs.git = {
    enable = true;
    settings = {
      user.name = name;
      user.email = email;
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
    mint-themes
    numix-icon-theme-circle
  ];

  # Desktop theming (conditional)
  gtk = lib.mkIf desktop {
    enable = true;
    theme = { name = "Mint-Y-Red"; package = pkgs.mint-themes; };
    iconTheme = { name = "Numix-Circle"; package = pkgs.numix-icon-theme-circle; };
    gtk4.theme = null;
  };

  home.activation = {

    # git clone public repos
    clonePublic = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

      export PATH="${pkgs.git}/bin:$PATH"
      export GIT_TERMINAL_PROMPT=0
      mkdir -p "${config.home.homeDirectory}/src"

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

    # git clone private repos (conditional)
    # Authentication failures must not prevent public desktop settings applying.
    clonePrivate = lib.mkIf private (lib.hm.dag.entryAfter
      (["clonePublic" "linkGeneration"] ++ lib.optionals desktop ["setupCinnamon" "setupGimp"]) ''

      export PATH="${pkgs.git}/bin:${pkgs.gh}/bin:$PATH"
      export GIT_TERMINAL_PROMPT=0
      mkdir -p "${config.home.homeDirectory}/src"

      if [ ! -d "${secret.dst}" ]; then
        git clone "${secret.src}" "${secret.dst}"
      fi

      if [ ! -d "${legacy.dst}" ]; then
        git clone "${legacy.src}" "${legacy.dst}"
      fi

    '');

    # desktop setup
    setupDconf = lib.mkIf desktop (lib.hm.dag.entryAfter ["clonePublic" "linkGeneration"] ''
      ${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon -- ${setupDconf}
    '');

    setupCinnamon = lib.mkIf desktop (lib.hm.dag.entryAfter ["setupDconf"] ''
      ${setupCinnamon}
    '');

    setupGimp = lib.mkIf desktop (lib.hm.dag.entryAfter ["clonePublic"] ''
      for dir in "$HOME"/.config/GIMP/*/; do
        if [ -d "$dir" ]; then
          ln -sfn "${exec.dst}/etc/gimp/shortcutsrc" "$dir/shortcutsrc"
        fi
      done
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
      # ".xprofile".text    = ''setxkbmap -option caps:escape'';
      # ".profile".source   = link "${personal.dst}/etc/profile";
      # ".profile".source   = lib.mkDefault (link "${personal.dst}/etc/profile");
      ".profile".source         = lib.mkForce (link "${personal.dst}/etc/profile");
      ".XCompose".source        = lib.mkForce (link "${personal.dst}/etc/XCompose");
      ".tmux.conf".source       = lib.mkForce (link "${personal.dst}/etc/tmux.conf");
      ".tmux.conf.local".source = lib.mkForce (link "${personal.dst}/etc/tmux.conf.local");
      "Templates".source        = link "${personal.dst}/etc/Templates";

      ".hotdogrc".text = ''This is not a config file'';

      ".config/fontconfig/conf.d/50-noto.conf".text = ''
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>

  <alias>
    <family>serif</family>
    <prefer>
${xmlFamilies ([ "Noto Serif" ] ++ notoSerifFallbacks)}
    </prefer>
  </alias>

  <alias>
    <family>sans-serif</family>
    <prefer>
${xmlFamilies ([ "Noto Sans" ] ++ notoSansFallbacks)}
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
${xmlFamilies ([ "Noto Sans Mono" ] ++ notoSansFallbacks)}
    </prefer>
  </alias>

  <alias>
    <family>Monospace</family>
    <prefer>
${xmlFamilies ([ "Noto Sans Mono" ] ++ notoSansFallbacks)}
    </prefer>
  </alias>

</fontconfig>
      '';
    }

    # Desktop-specific files (conditional)
    (lib.mkIf desktop {
      # ~/.local/share/icons
      ".local/share/icons/Numix-Circle/scalable/apps/obsidian.png".source = ./icons/obsidian.png;

      # ~/.local/share/applications
      ".local/share/applications/md.obsidian.Obsidian.desktop".text = ''
        [Desktop Entry]
        Categories=Office
        Comment=Knowledge base
        Exec=obsidian %u
        Icon=/home/jason/.local/share/icons/Numix-Circle/scalable/apps/obsidian.png
        MimeType=x-scheme-handler/obsidian
        Name=Obsidian
        StartupWMClass=md.obsidian.Obsidian
        Type=Application
        Version=1.5
      '';
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
    "${secret.dst}/bin/o"
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
    "autostart/setup-cinnamon.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Personal Cinnamon settings
      Exec=${setupCinnamon} --wait
      X-GNOME-Autostart-enabled=true
      NoDisplay=true
    '';

    # ~/.config/autostart/conky.desktop
    "autostart/conky.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Conky
        Exec=${personal.dst}/bin/conky-smart-start
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
