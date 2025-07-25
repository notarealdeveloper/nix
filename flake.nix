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

    devShells.${system}.work = 
      let
        python311 = pkgs.python311.override {
          packageOverrides = self: super: {
            numpy = pkgs.python311Packages.numpy_1;
          };
        };
      in
        pkgs.mkShell {
          buildInputs = [
            (python311.withPackages (ps: with ps; [
              #pip
              #setuptools
              ipython
              numpy
              #pandas
              #scikit-learn
              #lightgbm
              #lambda-multiprocessing
              tflite-runtime
            ]))
          ];
          doCheck = false;
        };

  };
}
