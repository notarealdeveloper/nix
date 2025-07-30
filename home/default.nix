{ pkgs, lib, config, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
  ];

  # gtk theme for cinnamon
  gtk = {
    enable = true;
    theme = {
      name = "Numix";
      package = pkgs.numix-gtk-theme;
    };
    iconTheme = {
      name = "Numix-Circle";
      package = pkgs.numix-icon-theme-circle;
    };
  };

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
