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

    aws-cvpn-client = {
      url = "github:sirn/aws-cvpn-client";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, nix-on-droid, aws-cvpn-client, ... }:

  let

    system = "x86_64-linux";

    overlay = final: prev:
      (import ./overlay/src final prev)
      //
      {
        aws-cvpn = aws-cvpn-client.packages.${prev.system}.default;
      };

    jasonHomeModules = [
      ./home/jason.nix

      # Avoid pulling sd-switch into the Home Manager activation closure.
      # The current nixpkgs sd-switch path depends on a broken mes fetch.
      { systemd.user.startServices = "suggest"; }
    ];

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ overlay ];
      config.allowUnfree = true;
    };

    # Generated hardware modules can be replaced verbatim after a reinstall.
    # Add a laptop here to give it both a full and a stage-one configuration.
    laptops = {
      turing = ./hw/system76.nix;
      kleene = ./hw/lenovo.nix;
    };

    laptopConfigurations = nixpkgs.lib.concatMapAttrs (hostName: hardware:
      let
        laptop = stageOne: nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            hardware
            ./os/linux-nixos.nix
            (if stageOne then ./configuration-stage-one.nix else ./configuration.nix)
            home-manager.nixosModules.home-manager
            ({ config, lib, ... }: {
              networking.hostName = hostName;
              # First activation clones the public dotfile repositories.
              systemd.services.home-manager-jason = {
                wants = [ "network-online.target" ];
                after = [ "network-online.target" ];
                # The default login shell sources our personal .profile, whose
                # X commands fail before login. Load only the system environment;
                # setupDconf supplies its own D-Bus session during activation.
                serviceConfig.ExecStart = lib.mkForce (toString (pkgs.writeShellScript "activate-jason-home" ''
                  . /etc/profile
                  exec ${config.home-manager.users.jason.home.activationPackage}/activate --driver-version ${if config.home-manager.enableLegacyProfileManagement then "0" else "1"}
                ''));
              };
              home-manager = {
                backupFileExtension = "backup";
                extraSpecialArgs = { desktop = true; private = !stageOne; };
                users.jason.imports = jasonHomeModules;
              };
            })
          ];
        };
      in {
        ${hostName} = laptop false;
        "${hostName}-stage-one" = laptop true;
      }
    ) laptops;

  in {

    nixosConfigurations = laptopConfigurations // {

      gates = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./os/windows-nixos.nix
          ./configuration.nix
          { networking.hostName = "gates"; }
          home-manager.nixosModules.home-manager
        ];
      };

    };

    homeConfigurations = {

      turing = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = jasonHomeModules;
        extraSpecialArgs = { inherit pkgs; desktop = true; private = true; };
      };

      kleene = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = jasonHomeModules;
        extraSpecialArgs = { inherit pkgs; desktop = true; private = true; };
      };

      gates = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = jasonHomeModules;
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
