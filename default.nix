# default.nix
let
  pkgs = (import <nixpkgs> {});
in {
  myenv = pkgs.buildEnv {
    name = "ld";
    paths = with pkgs; [
      cowsay
      (import ./python pkgs)
    ];
  };
}
