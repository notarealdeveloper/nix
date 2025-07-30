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

    isWsl    = !(builtins.getEnv "WSL_DISTRO_NAME" == "");
    isLinux  = pkgs.stdenv.isLinux;
    isDarwin = pkgs.stdenv.isDarwin;
    isNative = isLinux && !isWsl;

    platform-specific = (
      if isWsl then [
        nixos-wsl.nixosModules.wsl
        ./os/windows-nixos.nix
      ] else [
        ./os/linux-nixos.nix
      ]
    );

    modules = platform-specific ++ [
      ./users.nix
      ./configuration.nix
      home-manager.nixosModules.home-manager
    ];

  in {

    nixosConfigurations = rec {

      turing = nixpkgs.lib.nixosSystem {
        inherit system pkgs modules;
      };

      default = turing;
    };

    homeConfigurations = rec {

      jason = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/jason.nix ];
        extraSpecialArgs = { inherit pkgs; };
      };

      ramya = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/ramya.nix ];
        extraSpecialArgs = { inherit pkgs; };
      };

      default = jason;

    };

  };

}
