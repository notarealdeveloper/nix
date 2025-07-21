# default.nix
let
  pkgs = (import <nixpkgs> {});
in {
  myenv = pkgs.buildEnv {
    name = "ld";
    paths = with pkgs; [
      cowsay
      xorg.xeyes
      figlet
      toilet
      lolcat
      cmatrix
      asciiquarium
      gh
      google-chrome
      xclip
      (import ./python pkgs)
    ];
  };
}
