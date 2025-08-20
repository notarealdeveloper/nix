# overlay: self = final, prev = super
self: prev:

let
  # the helper cpython/default.nix expects
  passthruFun = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/passthru.nix")
    { };

  # CPython 3.15 source you pinned
  src315 = prev.fetchFromGitHub {
    owner = "python";
    repo  = "cpython";
    rev   = "7fda8b66debb24e0520b94c3769b648c7305f84e";
    hash  = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
  };

  # Build CPython using nixpkgs' cpython derivation, passing passthruFun.
  python315-base = prev.callPackage
    (prev.path + "/pkgs/development/interpreters/python/cpython")
    {
      self = self.python315;  # standard “self” threading used by nixpkgs
      sourceVersion = { major = "3"; minor = "15"; patch = "0"; suffix = "a0"; };
      # only used if a release tarball path is constructed
      hash = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
      inherit passthruFun;
    };

  python315 = python315-base.overrideAttrs (old: let
    oldPT = old.passthru or {};
    newDoc =
      if oldPT ? doc then oldPT.doc.overrideAttrs (_: { src = src315; }) else null;
  in {
    src = src315;
    passthru = oldPT // (if oldPT ? doc then { doc = newDoc; } else {});
  });

in
{
  # expose interpreter + package set
  python315 = python315;
  python315Packages = self.python315.pkgs;

  # optional: free-threaded variant, if you need it
  python315FreeThreading = self.python315.override {
    self = self.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
  };
}

