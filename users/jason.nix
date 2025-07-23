{ pkgs, lib, ... }:

{
  home.username      = "jason";
  home.homeDirectory = "/home/jason";
  home.stateVersion  = "25.05";   # keep this line

  programs.git = {
    enable    = true;
    userName  = "Jason Wilkes";
    userEmail = "notarealdeveloper@gmail.com";

    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase        = true;
    };
  };

  # conky autostart
  # creates ~/.config/autostart/conky.desktop
  xdg.configFile."autostart/conky.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Conky
    Exec=conky-smart-start
    X-GNOME-Autostart-enabled=true
    NoDisplay=false
    Comment=Start Conky at login
  '';

  home.activation.setNemoView = lib.hm.dag.entryAfter ["writeBoundary"] ''
    dconf write /org/nemo/preferences/default-folder-viewer "'list-view'"
  '';

  home.packages = with pkgs; [

    # terminal
    asciiquarium
    cmatrix
    figlet
    toilet
    dconf

    # lean
    lean4
  ];
}
