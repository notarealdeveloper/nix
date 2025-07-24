# python/extend.nix
# This is a pythonPackages *scope* extension: self = the extended scope, super = old scope

self: super:
let
  call = super.callPackage;
in {

  callable_module = call ./callable-module.nix {};
  is_instance     = call ./is-instance.nix { inherit (self) callable_module; };
  assure          = call ./assure.nix {};
  mmry            = call ./mmry.nix {};
  embd            = call ./embd.nix { inherit (self) is_instance assure mmry; };
  kern            = call ./kern.nix { inherit (self) assure mmry; };
  wnix            = call ./wnix.nix { inherit (self) assure mmry is_instance embd kern; };

  jello = call ./jello.nix {
    inherit (super) lib stdenv fetchFromGitHub;
    inherit (self) buildPythonPackage setuptools wheel;
  };
}
