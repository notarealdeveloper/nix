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

    mkHome = { user, desktop ? true }: hmLib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ user ];
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

    homeConfigurations = rec {
      jason     = mkHome { ./home/jason.nix; };
      ramya     = mkHome { ./home/ramya.nix; };
      luna      = mkHome { ./home/luna.nix;  };
      headless  = mkHome { ./home/jason.nix; desktop = false; };
      default   = jason;
    };

  };
}

