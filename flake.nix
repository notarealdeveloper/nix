{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs: {

    nixosConfigurations.turing = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./turing.nix
      ];
    };


    nixosConfigurations.gates = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./gates.nix
      ];
    };

  };
}
