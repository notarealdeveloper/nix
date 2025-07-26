# overlay.nix
final: prev: rec {

  ############################
  ### Existing Executables ###
  ############################

  sl2 = import ./bin/sl2.nix final prev;

  python-head = import ./python/python-head.nix final prev; # work in progress

  #########################
  ### Local Executables ###
  #########################

  hello = import ./bin/hello.nix { inherit (prev) stdenv fetchFromGitHub; };

  yello = import ./bin/yello.nix prev prev.python3;

  ######################
  ### Python Overlay ###
  ######################

  # Note: Once you have multiple overlays, include them like this
  # pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [ (import ./python/extend.nix prev) ];

  # 1) Register your extension so *every* pythonXPackages set sees it.
  pythonPackagesExtensions = [ (import ./python/extend.nix prev ) ];

  # 2) (Optional) Expose them at top-level too, like normal pkgs:
  # inherit (final.python3Packages) callable_module is_instance assure mmry embd kern wnix jello;

}
