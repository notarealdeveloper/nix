{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";
  common    = (import ./common.nix user);
  gitconfig = (import ./lib/git.nix name email);

  system = import ./lib/system.nix { inherit pkgs lib config; };
  inherit (system) nixos exec personal;

in {

  imports = [
    common
    gitconfig
    ./lib/public.nix
    ./lib/private.nix
    (if desktop then ./lib/desktop.nix else ./lib/none.nix)
  ];

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

  # Keep this line
  home.stateVersion  = "25.05";
}
