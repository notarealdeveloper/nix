{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }:
  let

    system  = "x86_64-linux";

    overlay = import ./overlay;

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ overlay ];
      config = { allowUnfree = true; };
    };

  in {

    nixosConfigurations = {

      turing = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          home-manager.nixosModules.home-manager
          nixos-wsl.nixosModules.wsl
          ./configuration.nix
        ];
      };

    };

  };
}
