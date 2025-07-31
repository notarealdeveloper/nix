user: name: email: (

  { pkgs, lib, config, ... }:

    home.username = user;
    home.homeDirectory = "/home/${user}";

    home.sessionVariables = {
      EDITOR = "vim";
    };

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

)
