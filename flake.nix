{
  description = "The WNIX Operating System";

  inputs = {

    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    doubleunix-overlay = {
      url = "github:doubleunix/overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aws-cvpn-client = {
      url = "github:sirn/aws-cvpn-client";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, doubleunix-overlay, nix-on-droid, aws-cvpn-client, ... }:

  let

    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        doubleunix-overlay.overlays.default
      ];
      config.allowUnfree = true;
    };

    mkSystem = { hw, os, name }:
      nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          hw
          os
          ./configuration.nix
          { networking.hostName = name; }
          home-manager.nixosModules.home-manager
        ];
        specialArgs = {
          inherit aws-cvpn-client;
          inherit doubleunix-overlay;
        };
      };
  in {

    nixosConfigurations = {

      turing = mkSystem {
        hw = ./hardware/system76.nix;
        os = ./os/linux-nixos.nix;
        name = "turing";
      };

      kleene = mkSystem {
        hw = ./hardware/lenovo.nix;
        os = ./os/linux-nixos.nix;
        name = "kleene";
      };

      gates = mkSystem {
        hw = nixos-wsl.nixosModules.wsl;
        os = ./os/windows-nixos.nix;
        name = "gates";
      };

    };

    homeConfigurations =
      let

        self = "jason";

        mkhome = { user ? self, desktop ? true }:
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./home/${self}.nix ];
            extraSpecialArgs = {
              inherit pkgs;
              desktop = desktop;
            };
          };

      in
        {

          turing    = mkhome {};
          kleene    = mkhome {};
          gates     = mkhome { desktop = false; };
          luna      = mkhome { user = "luna";  };

        };

    nixOnDroidConfigurations = rec {
      phone = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [ ./os/android-nixos.nix ];
      };
      default = phone;
    };

    packages.${system} = pkgs;

    legacyPackages.${system} = pkgs;

  };
}

