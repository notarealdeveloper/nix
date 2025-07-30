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
        ./nixos/wsl.nix
      ] else [
        ./nixos/native.nix
      ]
    );

    modules = platform-specific ++ [
      ./configuration.nix
      home-manager.nixosModules.home-manager
    ];

  in {

    nixosConfigurations = {
      turing = nixpkgs.lib.nixosSystem {
        inherit system pkgs modules;
      };
    };

  };

}
