{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
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

}
