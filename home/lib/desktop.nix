{ pkgs, lib, config, ... }:

let

    icons = pkgs.numix-icon-theme-circle;
    theme = pkgs.numix-gtk-theme;

in {

  home.packages = with pkgs; [
    theme
    icons
  ];

  gtk = {
    enable = true;
    theme = { name = "Numix"; package = theme; };
    iconTheme = { name = "Numix-Circle"; package = icons; };
  };

  home.file = {

    # ~/.local/share/icons
    ".local/share/icons/Numix-Circle/scalable/apps/obsidian.png".source = ./icons/obsidian.png;

    # ~/.local/share/applications
    ".local/share/applications/obsidian.desktop".text =
        let
          src = builtins.readFile "${pkgs.obsidian}/share/applications/obsidian.desktop";
          icon = "${config.home.homeDirectory}/.local/share/icons/Numix-Circle/scalable/apps/obsidian.png";
        in
          builtins.replaceStrings ["Icon=obsidian"] ["Icon=${icon}"] src;
  };

}
