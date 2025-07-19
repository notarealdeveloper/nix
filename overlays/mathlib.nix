self: super:

{
  lean4Mathlib = super.stdenv.mkDerivation {
    pname = "lean4-mathlib";
    version = "0.1";

    src = builtins.fetchGit {
      url = "https://github.com/leanprover-community/mathlib4";
      ref = "master";  # or pin a commit
    };

    buildInputs = [ super.lean4 super.git ];

    doCheck = false;

    buildPhase = ''
      echo "Building mathematics."
      # lake build
      # This doesn't work. Figure out why.
    '';

    installPhase = ''
      mkdir -p $out/share/lean
      cp -r $src $out/share/lean/mathlib4
    '';
  };
}
