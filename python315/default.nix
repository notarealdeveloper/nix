# self = final; super = prev
self: super:

let
  src315 = super.fetchFromGitHub {
    owner = "python";
    repo  = "cpython";
    rev   = "7fda8b66debb24e0520b94c3769b648c7305f84e";
    hash  = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
  };

  # Build CPython using nixpkgs' cpython derivation, but with 3.15 inputs.
  # We call the same cpython package as nixpkgs does, then override src/doc.
  python315-base = super.callPackage
    (super.path + "/pkgs/development/interpreters/python/cpython")
    {
      self = self.python315;  # standard “self” threading used by nixpkgs
      sourceVersion = { major = "3"; minor = "15"; patch = "0"; suffix = "a0"; };
      # This hash is only used if the builder fetches a tarball itself.
      hash = "sha256-lNrDERJPfoo/a5629/fS0RbBYdh3CtXrbA0rFKw+eAQ=";
      inherit (super) stdenv;  # ensure we don't accidentally swap toolchains
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
  # Expose the interpreter + its package set like other pythons do
  python315 = python315;
  python315Packages = self.python315.pkgs;

  # (Optional) Free-threaded variant, matching your fork
  python315FreeThreading = self.python315.override {
    self = self.python315FreeThreading;
    pythonAttr = "python315FreeThreading";
    enableGIL = false;
  };

  # Patch html5lib in all python package sets via the official extension hook.
  # This limits the change to the python ecosystem; it won't touch stdenv.
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pySelf: pySuper: {
      html5lib = pySuper.html5lib.overrideAttrs (old: {
        doCheck = false;  # same as upstream’s setting in your diff
        postPatch = (old.postPatch or "") + ''
          # py3.15: ast.Str alias is gone – use ast.Constant[str]
          substituteInPlace setup.py \
            --replace \
              "isinstance(a.value, ast.Str)" \
              "isinstance(a.value, ast.Constant) && isinstance(a.value.value, str)"
        '';
      });
    })
  ];
}

