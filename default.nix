# default.nix
let
  pkgs = (import <nixpkgs> {});
in {
  myenv = pkgs.buildEnv {
    name = "ld";
    paths = with pkgs; [
      vim
      git
      gh
      cowsay
      xcowsay
      xorg.xeyes
      figlet
      toilet
      lolcat
      cmatrix
      asciiquarium
      gh
      xdg-utils
      google-chrome
      xclip
      (import ./python pkgs)
    ];
  };
}
