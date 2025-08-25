# Repository configuration and cloning logic
{ lib, config, pkgs, ... }:

let
  src = "/home/${config.home.username}/src";
  link = config.lib.file.mkOutOfStoreSymlink;

  # Repository definitions
  repos = {
    # System configuration
    nix = {
      url = "https://github.com/notarealdeveloper/nix";
      path = "${src}/nix";
    };

    # Team repositories  
    exec = {
      url = "https://github.com/thedynamiclinker/exec";
      path = "${src}/exec";
    };

    # Personal repositories
    personal = {
      url = "https://github.com/notarealdeveloper/personal";
      path = "${src}/personal";
    };

    # Private repositories (require auth)
    secret = {
      url = "https://github.com/notarealdeveloper/secret";
      path = "${src}/secret";
      private = true;
    };

    legacy = {
      url = "https://github.com/notarealdeveloper/legacy";
      path = "${src}/legacy";
      private = true;
    };
  };

  # Generate clone commands for public repos
  clonePublicRepos = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: repo: ''
      if [ ! -d "${repo.path}" ]; then
        git clone "${repo.url}" "${repo.path}"
      fi
    '') (lib.filterAttrs (name: repo: !(repo.private or false)) repos)
  );

  # Generate clone commands for private repos
  clonePrivateRepos = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: repo: ''
      if [ ! -d "${repo.path}" ]; then
        git clone "${repo.url}" "${repo.path}"
      fi
    '') (lib.filterAttrs (name: repo: repo.private or false) repos)
  );

in {
  # Export repos for use in other modules
  _module.args.repos = repos;

  # Clone public repositories
  home.activation.clonePublic = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''
    export PATH="${pkgs.git}/bin:$PATH"
    ${clonePublicRepos}
  '';

  # Clone private repositories  
  home.activation.clonePrivate = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''
    export PATH="${pkgs.git}/bin:$PATH"
    ${clonePrivateRepos}
  '';

  # Add repository bins to PATH
  home.sessionPath = [
    repos.exec.path + "/bin"
    repos.personal.path + "/bin"
    repos.secret.path + "/bin"
  ];

  # Source repository bashrc files
  programs.bash.bashrcExtra = ''
    source "${repos.exec.path}/etc/bashrc"
    source "${repos.personal.path}/etc/bashrc"
    source "${repos.secret.path}/etc/bashrc"
  '';

  # Common file symlinks
  home.file = {
    # From exec repo
    ".vimrc".source = link "${repos.exec.path}/etc/vimrc";
    ".face".source = link "${repos.exec.path}/etc/dot-face";
    ".ipython/profile_default/startup/00-pyrc.py".source = link "${repos.exec.path}/bin/pyrc";

    # From personal repo
    "Templates".source = link "${repos.personal.path}/etc/Templates";

    # From secret repo
    ".pypirc".source = link "${repos.secret.path}/etc/pypirc";
    ".netrc".source = link "${repos.secret.path}/etc/netrc";
    ".ssh".source = link "${repos.secret.path}/etc/ssh";
    ".config/glab-cli/config.yml".source = link "${repos.secret.path}/etc/glab-cli-config.yml";

    # Auto-generated files
    ".hotdogrc".text = "This is not a config file";
  };

  # Desktop autostart configuration
  xdg.configFile."autostart/conky.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Conky
    Exec=${repos.personal.path}/conky-smart-start
    X-GNOME-Autostart-enabled=true
    NoDisplay=false
    Comment=Start Conky at login
  '';
}
