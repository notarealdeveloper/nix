{
  description = "NixOS configurations";

  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: {

    nixosConfigurations.turing = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
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
