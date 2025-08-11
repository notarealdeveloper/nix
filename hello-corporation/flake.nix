{
  description = "Hello Corporation Developer Environment©®™";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = func:

      nixpkgs.lib.genAttrs systems (system:

        let

          pkgs   = import nixpkgs { inherit system; };

          python = pkgs.python313;

          helloBanner = ''
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
              Rust
              - $(rustc --version)
              - $(cargo --version)
              Haskell
              - $(ghc --version)
              - $(cabal --version | head -1)
              Python
              - $(python --version)
            ==============================================
            EOF

            export PS1="(hello) $PS1"
          '';

          basePackages = with pkgs; [
            # basics
            git
            gnumake

            # C toolchain
            gcc autoconf automake libtool pkg-config meson ninja

            # Python (3.13) + libs
            (python.withPackages (ps: with ps; [ pip setuptools build pytest twine wheel cython ]))

            # Rust
            rustc cargo

            # Haskell
            ghc cabal-install
          ];
        in
        func pkgs python helloBanner basePackages
      );

  in
  {

    packages = forAllSystems (pkgs: python: helloBanner: basePackages: {
      hello-corporation = pkgs.writeShellApplication {
        name = "hello-corporation";
        runtimeInputs = basePackages;
        text = helloBanner;
      };

      default = self.packages.${pkgs.system}.hello-corporation;
    });

    devShells = forAllSystems (pkgs: python: helloBanner: basePackages: {
      default = pkgs.mkShell {
        name = "hello-corporation";
        packages = basePackages;
        shellHook = helloBanner;
        SHELL = pkgs.bashInteractive;
      };
    });
  };
}

