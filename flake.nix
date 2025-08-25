{
  description = "The WNIX Operating System";

  inputs = {

    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    doubleunix = {
      url = "github:doubleunix/overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, nix-on-droid, doubleunix, ... }:

  let

    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ doubleunix.overlays.default ];
      config.allowUnfree = true;
    };

  in {

    nixosConfigurations = {

      turing = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./hw/system76.nix
          ./os/linux-nixos.nix
          ./configuration.nix
          { networking.hostName = "turing"; }
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit doubleunix-overlay; };
      };

      kleene = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./hw/lenovo.nix
          ./os/linux-nixos.nix
          ./configuration.nix
          { networking.hostName = "kleene"; }
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit doubleunix-overlay; };
      };

      gates = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./os/windows-nixos.nix
          ./configuration.nix
          { networking.hostName = "gates"; }
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit doubleunix-overlay; };
      };

    };

    homeConfigurations =

      let

        self = "jason";

        mkhome = { user, desktop ? true, private ? true }:
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./home/${user}.nix ];
            extraSpecialArgs = {
              inherit pkgs;
              desktop = desktop;
              private = private;
            };
          };

      in {

        turing = mkhome { user = self; };
        kleene = mkhome { user = self; };
        gates  = mkhome { user = self; desktop = false; };

        luna = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/luna.nix ];
        };

      };

    nixOnDroidConfigurations = rec {
      phone = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [
          ./os/android-nixos.nix
          #home-manager.nixosModules.home-manager
        ];
      };
      default = phone;
    };

    #packages.${system} = pkgs;

    #legacyPackages.${system} = pkgs;

  };
}
