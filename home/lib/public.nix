# public.nix

{ pkgs, lib, config, ... }:

let

  system = import ./system.nix { inherit pkgs lib config; };
  inherit (system) nixos exec personal;

  link = config.lib.file.mkOutOfStoreSymlink;

in

{

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

  home.file = lib.mkMerge [{

    # symlinks from exec
    ".vimrc".source     = link "${exec.dst}/etc/vimrc";
    ".face".source      = link "${exec.dst}/etc/dot-face";

    # ipython startup file
    ".ipython/profile_default/startup/00-pyrc.py".source = link "${exec.dst}/bin/pyrc";

    # symlinks from personal
    "Templates".source  = link "${personal.dst}/etc/Templates";

    # auto-generated
    ".hotdogrc".text    = ''This is not a config file'';

  }];

  # PATH for interactive shells
  # home.sessionVariables.PATH = lib.mkBefore "${exec.dst}/bin:${personal.dst}/bin";


  # PATH for login shells
  home.sessionPath = [
    "${exec.dst}/bin"
    "${personal.dst}/bin"
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${exec.dst}/etc/bashrc"
      source "${personal.dst}/etc/bashrc"
    '';
  };

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

}
