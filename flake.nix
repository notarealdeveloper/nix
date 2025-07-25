{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system  = "x86_64-linux";
    overlay = import ./overlay.nix;
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ overlay ];
      config = {
        allowUnfree = true;
      };
    };

  in {

    nixosConfigurations = {

      turing = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          home-manager.nixosModules.home-manager
          ./turing.nix
        ];
      };

      gates = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          home-manager.nixosModules.home-manager
          ./gates.nix
        ];
      };

    };

    devShells.${system}.work = pkgs.mkShell {
      buildInputs = [
        (pkgs.python311.withPackages (ps: with ps; [
          pip
          setuptools
          ipython
          (ps.numpy.overridePythonAttrs (old: rec {
            version = "1.26.4";
            src = pkgs.fetchPypi {
              pname = "numpy";
              inherit version;
              sha256 = "666dbfb6ec68962c033a450943ded891bed2d54e6755e35e5835d63f4f6931d5";
            };
          }))
          pandas
          scikit-learn
          lightgbm
          lambda-multiprocessing
          tflite-runtime
        ]))
      ];
    };

  };
}
