{
  description = "The WNIX Operating System";

  inputs = {

    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-unstable";
    #wnixpkgs.url = "github:doubleunix/wnixpkgs/wnixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    overlay = {
      url = "github:doubleunix/overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aws-cvpn-client = {
      url = "github:sirn/aws-cvpn-client";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, overlay, aws-cvpn-client, ... }:

  let

    system = "x86_64-linux";

    overlay-python-head = import ./python;

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        overlay.overlays.default
        overlay-python-head
      ];
      config.allowUnfree = true;
    };

    mkHome = { user, desktop ? true }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/${user}.nix ];
        extraSpecialArgs = {
          inherit pkgs;
          desktop = desktop;
        };
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
        specialArgs = { inherit aws-cvpn-client; };
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

    homeConfigurations = rec {

      turing    = mkHome { user = "jason"; };
      kleene    = mkHome { user = "jason"; };
      gates     = mkHome { user = "jason"; desktop = false; };

      jason     = mkHome { user = "jason"; };
      ramya     = mkHome { user = "ramya"; };
      luna      = mkHome { user = "luna";  };
      mei       = mkHome { user = "mei"; };

    };

    # Make sure this doesn't break the cool remote
    # searchability thing before removing it.
    # For now, nix flake check seems not to like it.
    # packages.${system} = pkgs;

    packages.${system} = pkgs;

    legacyPackages.${system} = pkgs;

  };
}

