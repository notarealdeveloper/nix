{
  description = "The WNIX Operating System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }:
  let
    system = "x86_64-linux";

    overlay = import ./overlay;

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ overlay ];
      config.allowUnfree = true;
    };

    hmLib = home-manager.lib;
    hmMod = home-manager.nixosModules.home-manager;

    mkHome = desktop: hmLib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home/jason.nix ];
      extraSpecialArgs = {
        inherit pkgs;
        desktop = desktop;
      };
    };
  in {
    nixosConfigurations = {
      turing = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./hardware/system76.nix
          ./os/linux-nixos.nix
          ./users.nix
          ./configuration.nix
          hmMod
        ];
      };

      kleene = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./hardware/lenovo.nix
          ./os/linux-nixos.nix
          ./users.nix
          ./configuration.nix
          hmMod
        ];
      };

      gates = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./os/windows-nixos.nix
          ./users.nix
          ./configuration.nix
          hmMod
        ];
      };
    };

    homeConfigurations = {
      jason = mkHome true;
      jason-no-desktop = mkHome false;
      default = mkHome true;
    };
  };
}

