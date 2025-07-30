{ pkgs, lib, config, ... }:

user:

let

  # TODO: Add ~/.config/mimeapps.list setup

  user = user;
  link = config.lib.file.mkOutOfStoreSymlink;

  # system
  nixos = {
    src = "https://github.com/notarealdeveloper/nixos";
    dst = "${config.home.homeDirectory}/src/nixos";
  };

  exec = {
    src = "https://github.com/thedynamiclinker/exec";
    dst = "${config.home.homeDirectory}/src/exec";
  };

  personal = {
    src = "https://github.com/notarealdeveloper/personal";
    dst = "${config.home.homeDirectory}/src/personal";
  };

  # requires auth
  secret = {
    src = "https://github.com/notarealdeveloper/secret";
    dst = "${config.home.homeDirectory}/src/secret";
  };

  # requires auth
  legacy = {
    src = "https://github.com/notarealdeveloper/legacy";
    dst = "${config.home.homeDirectory}/src/legacy";
  };

  numix-icons = pkgs.numix-icon-theme-circle;

in

{
  imports = [ ];

  home.username = user;
  home.homeDirectory = "/home/${user}";

  home.sessionVariables = {
    EDITOR = "vim";
  };

  nixpkgs.config.allowUnfree = true;

  # git clone repos if not present
  home.activation.cloneExec = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

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
    if [ ! -d "${secret.dst}" ]; then
      git clone "${secret.src}" "${secret.dst}"
    fi
    if [ ! -d "${legacy.dst}" ]; then
      git clone "${legacy.src}" "${legacy.dst}"
    fi
  '';

  # ~/.config/git
  programs.git = {
    enable    = true;
    userName  = "Jason Wilkes";
    userEmail = "notarealdeveloper@gmail.com";
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

  home.file = {

    # symlinks from exec
    ".vimrc".source     = link "${exec.dst}/etc/vimrc";
    ".face".source      = link "${exec.dst}/etc/dot-face";

    # symlinks from personal
    "Templates".source  = link "${personal.dst}/etc/Templates";

    # symlinks from secret: for the low-risk subset of secrets
    # that a private repo with multifactor is sufficiently secure for.
    #
    # for the higher-risk subset of secrets, the secret should
    # generally never leave the machine it was generated on.
    ".pypirc".source    = link "${secret.dst}/etc/pypirc";
    ".netrc".source     = link "${secret.dst}/etc/netrc";
    ".ssh".source       = link "${secret.dst}/etc/ssh";

    # auto-generated
    ".hotdogrc".text    = ''This is not a config file'';
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${exec.dst}/etc/bashrc"
      source "${personal.dst}/etc/bashrc"
      source "${secret.dst}/etc/bashrc"
    '';
  };

  # PATH for interactive shells
  home.sessionVariables.PATH = "${exec.dst}/bin:${personal.dst}/bin:${secret.dst}/bin:$HOME/.local/bin:$PATH";

  # PATH for login shells
  home.sessionPath = [
    "${exec.dst}/bin"
    "${personal.dst}/bin"
    "${secret.dst}/bin"
    "$HOME/.local/bin"
  ];

  home.packages = with pkgs; [
    git
    dconf
    dconf-editor
    dbus # wsl
    gnome-terminal
    xcowsay
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
      package = numix-icons;
    };
  };

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

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
