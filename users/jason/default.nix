{ pkgs, lib, ... }:

{
  home.username      = "jason";
  home.homeDirectory = "/home/jason";
  home.stateVersion  = "25.05";   # keep this line

  imports = [
    ./org-cinnamon-desktop-keybindings.nix
  ];

  # ~/.config/git/config
  programs.git = {
    enable    = true;
    userName  = "Jason Wilkes";
    userEmail = "notarealdeveloper@gmail.com";

    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase        = true;
    };
  };

  # gh
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  # ~/.config/autostart/conky.desktop
  xdg.configFile."autostart/conky.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Conky
    Exec=conky-smart-start
    X-GNOME-Autostart-enabled=true
    NoDisplay=false
    Comment=Start Conky at login
  '';

  # /org/nemo/preferences/default-folder-viewer
  dconf.settings = {
    "org/nemo/preferences" = {
      "default-folder-viewer" = "list-view";
    };
  };

  home.packages = with pkgs; [

    # terminal
    asciiquarium
    cmatrix
    figlet
    toilet
    dconf
    home-manager

    # lean
    lean4
  ];

}
