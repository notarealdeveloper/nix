# public.nix

# ------------------------------------------
# all content can be divided into six types.
# ------------------------------------------
#  u  g  o: columns defined as in unix chmod
# ------------------------------------------
# 1. rw rw rw: pure wiki, almost nonexistent
# 2. rw rw r-: open source team
# 3. rw rw --: closed source team
# 4. rw r- r-: open source personal
# 5. rw r- --: closed source personal
# 6. rw -- --: closed source secret
#
# note: the execute bit is not included
# because it isn't real, citation here:
# https://youtu.be/o5cASgBEXWY&t=240
#
# this type system is sufficient for most
# practical purposes to distinguish all the
# different permission levels in a typical
# developer's life. in what follows, when
# we refer to "the rw rw r- parts of life"
# etc, we're referring to a repo with the
# scope described in the list above.

{ pkgs, lib, config, ... }:

let

  link = config.lib.file.mkOutOfStoreSymlink;

  # system
  nixos = {
    src = "https://github.com/notarealdeveloper/nixos";
    dst = "${config.home.homeDirectory}/src/nixos";
  };


  # team stuff: the "rw rw r-" parts of life
  #
  # note: it is an exercise for the reader to
  # determine why a group called thedynamiclinker
  # would choose the name exec to refer to their
  # shared code
  exec = {
    src = "https://github.com/thedynamiclinker/exec";
    dst = "${config.home.homeDirectory}/src/exec";
  };

  # personal stuff: the "rw r- r-" parts of life
  #
  # note: this is private in the sense of being specific
  # to my workflow but not the workflow of others. this
  # sense of the term "personal" is not to be confused
  # with the sense that means "secret". for that stuff,
  # see the note below, and the file it points to.
  personal = {
    src = "https://github.com/notarealdeveloper/personal";
    dst = "${config.home.homeDirectory}/src/personal";
  };

  # secret stuff: the "rw -- --" parts of life
  #
  # are fetched in private.nix, but before doing
  # so we have to `gh auth login` with two-factor
  # secrets that (obviously) aren't stored in there
  # public text files.
in

{
  imports = [ ];


  # git clone public repos
  home.activation.clonePublic = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

    export PATH="${pkgs.git}/bin:$PATH"

    if [ ! -d "${nixos.dst}" ]; then
      git clone "${nixos.src}" "${nixos.dst}"
    fi

    if [ ! -d "${exec.dst}" ]; then
      git clone "${exec.src}" "${exec.dst}"
    fi

    if [ ! -d "${personal.dst}" ]; then
      git clone "${personal.src}" "${personal.dst}"
    fi

  '';

  home.file = {

    # symlinks from exec
    ".vimrc".source     = link "${exec.dst}/etc/vimrc";
    ".face".source      = link "${exec.dst}/etc/dot-face";

    # symlinks from personal
    "Templates".source  = link "${personal.dst}/etc/Templates";

    # auto-generated
    ".hotdogrc".text    = ''This is not a config file'';

  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${exec.dst}/etc/bashrc"
      source "${personal.dst}/etc/bashrc"
    '';
  };

  # PATH for interactive shells
  home.sessionVariables.PATH = "${exec.dst}/bin:${personal.dst}/bin:$HOME/.local/bin:$PATH";

  # PATH for login shells
  home.sessionPath = [
    "${exec.dst}/bin"
    "${personal.dst}/bin"
    "$HOME/.local/bin"
  ];

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

  home.activation.setupDconf = lib.hm.dag.entryAfter ["installPackages"] ''
    export PATH="${config.home.path}/bin:$PATH"
    "${personal.dst}/bin/setup-dconf"
  '';

  home.activation.setupCinnamon = lib.hm.dag.entryAfter ["setupDconf"] ''
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

  home.activation.setupGnomeTerminal = lib.hm.dag.entryAfter ["installPackages"] ''
    # we need gsettings and dconf for setup-gnome-terminal
    export PATH="${config.home.path}/bin:${pkgs.glib}/bin:$PATH"
    "${personal.dst}/bin/setup-gnome-terminal"
  '';

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
