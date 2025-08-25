{ pkgs, lib, config, ... }:

let

    src = pkgs.callPackage ./src.nix { };
    inherit (src) personal;

in {

  home.packages = with pkgs; [
    numix-gtk-theme
    numix-icon-theme-circle
  ];

  gtk = {
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

}
