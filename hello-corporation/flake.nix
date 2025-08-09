{
  description = "Hello Corporation Developer Environment©®™";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:

  let

    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system:

      let

        pkgs = import nixpkgs { inherit system; };

        pypkgs = pkgs.python313;

      in

        f pkgs pypkgs

    );

  in

  {

    devShells = forAllSystems (pkgs: py:

      {

        default = pkgs.mkShell {

          name = "hello-corporation";

          packages = with pkgs; [

            ################################
            ### Hello Technologies © ® ™ ###
            ################################

            # basics
            git
            gnumake

            # c
            gcc
            autoconf
            automake
            libtool
            pkg-config
            meson
            ninja

            # python
            (py.withPackages (ps: with ps; [
              setuptools
              wheel
              cython
            ]))

            # rust
            rustc
            cargo

            # haskell
            ghc
            cabal-install

          ];

          shellHook = ''
            cat << EOF
            ==============================================
             Hello Corporation environment is ready.  ✅
              Basics
              - $(git --version)
              - $(make --version | head -1)
              C
              - $(gcc --version | head -1)
              - $(autoconf --version | head -1)
              - $(meson --version)
              - $(ninja --version)
              Python
              - $(python --version)
              - packages: $(echo && pip list)
              Rust
              - $(rustc --version)
              - $(cargo --version)
              Haskell
              - $(ghc --verison)
              - $(cabal --version)
            ==============================================
            EOF
          '';
        };
      }
    );
  };
}

