#################
### flake.nix ###
#################

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

  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, nix-on-droid, ... }:

  let

    system = "x86_64-linux";

    overlay = import ./overlay/src;

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ overlay ];
      config.allowUnfree = true;
    };

    wnixpkgs = {
      # py313 = pkgs.python313.withPackages (ps: with ps; [
      py314 = pkgs.python314.withPackages (ps: with ps; [
        pip build pytest setuptools cython
        ipython sly curio
        requests beautifulsoup4 selenium
        numpy sympy editdistance
        scipy pandas matplotlib pycairo pyqt6
        seaborn scikit-learn
        h5py pillow
        google-auth-oauthlib
        google-api-python-client
        geoip2
        lz4

        assure
        is-instance
        python-bin
        mmry
        webfs
        lambda-multiprocessing
      ]);
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
        specialArgs = { inherit wnixpkgs; };
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
        specialArgs = { inherit wnixpkgs; };
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
        specialArgs = { inherit wnixpkgs; };
      };

    };

    homeConfigurations = {

      turing = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/jason.nix ];
        extraSpecialArgs = { inherit pkgs; desktop = true; private = true; };
      };

      kleene = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/jason.nix ];
        extraSpecialArgs = { inherit pkgs; desktop = true; private = true; };
      };

      gates = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/jason.nix ];
        extraSpecialArgs = { inherit pkgs; desktop = false; private = true; };
      };

      localhost = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [ ./os/android-nixos.nix ];
      };

      luna = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/luna.nix ];
      };

    };

    nixOnDroidConfigurations = rec {
      localhost = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [ ./os/android-nixos.nix ];
      };
      default = localhost;
    };

  };
}
