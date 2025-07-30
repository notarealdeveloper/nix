{ pkgs, lib, config, ... }:

let

  modules = [ ./default.nix ];

  user = "ramya";
  name = "Ramya Kottapalli";
  email = "ramya@thedynamiclinker.com";

  link = config.lib.file.mkOutOfStoreSymlink;

  exec = {
    src = "https://github.com/thedynamiclinker/exec";
    dst = "${config.home.homeDirectory}/src/exec";
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

  # git clone repos if not present
  home.activation.cloneExec = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

    export PATH="${pkgs.git}/bin:$PATH"

    if [ ! -d "${exec.dst}" ]; then
      git clone "${exec.src}" "${exec.dst}"
    fi
  '';

  home.file = {

    # symlinks from exec
    ".vimrc".source     = link "${exec.dst}/etc/vimrc";
    ".face".source      = link "${exec.dst}/etc/dot-face";

    # auto-generated
    ".hotdogrc".text    = ''This is not a config file'';
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${exec.dst}/etc/bashrc"
    '';
  };

  # PATH for interactive shells
  home.sessionVariables.PATH = "${exec.dst}/bin:$HOME/.local/bin:$PATH";

  # PATH for login shells
  home.sessionPath = [
    "${exec.dst}/bin"
    "$HOME/.local/bin"
  ];

  home.packages = with pkgs; [
    git
    gh
  ];

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
