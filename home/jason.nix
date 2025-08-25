{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

  src = import ./src.nix { };
  inherit (src) nix exec personal;

in {

  home.packages = with pkgs; [
    git
    dconf
    inotify-tools
  ];

  imports =
    [ (import ./base.nix { inherit user; }) ]
    ++
    [ ./public.nix ./private.nix ]
    ++
    (if desktop then [ ./desktop.nix ] else [])
  ;

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

  home.activation = if desktop then {

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

  } else {};

}
