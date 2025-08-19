# python/extend.nix
# This is a pythonPackages *scope* extension: self = the extended scope, super = old scope
pkgs:

  self: super:

  {

    jello = self.callPackage ./jello.nix {
      inherit (pkgs) lib stdenv fetchFromGitHub;
      inherit (self) buildPythonPackage setuptools wheel pip;
    };

  }
