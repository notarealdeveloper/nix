{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "jason";
  name = "Jason Wilkes";
  email = "notarealdeveloper@gmail.com";

  src = import ./src.nix;
  inherit (src) personal;

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

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  # Don't delete this
  home.stateVersion = "25.05";
}
