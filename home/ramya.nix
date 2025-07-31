{ pkgs, lib, config, ... }:

let

  user = "ramya";
  name = "Ramya Kottaplli";
  email = "rskottap@gmail.com";

in {

  imports = [
    (import ./lib/git.nix user name email)
    ./lib/github-public.nix
    ./lib/common.nix
  ];

}
