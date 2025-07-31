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

    #sysVendor = builtins.unsafeDiscardStringContext (pkgs.runCommandLocal "get-sys-vendor" {} ''
    #  cat /sys/class/dmi/id/sys_vendor > $out
    #'');

    #sysVendor  = builtins.unsafeDiscardStringContext (builtins.readFile /sys/class/dmi/id/sys_vendor);
    #isLenovo   = sysVendor == "LENOVO\n";
    #isSystem76 = sysVendor == "To be determined...\n";

    #hardware-specific = (
    #  if isWsl then [] else
    #  (
    #    if isSystem76 && isNative then [./hardware/system76.nix]
    #    else if isLenovo && isNative then [./hardware/lenovo.nix]
    #    else []
    #  )
    #);

    # TODO: try: builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop"; 

    platform-specific = (
      if isWsl then [
        nixos-wsl.nixosModules.wsl
        ./os/windows-nixos.nix
      ] else [
        ./os/linux-nixos.nix
      ]
    );

    hmmod = home-manager.nixosModules.home-manager;
    hmlib = home-manager.lib;

  in {

    nixosConfigurations = rec {

      turing = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./hardware/system76.nix
          ./os/linux-nixos.nix
          ./users.nix
          ./configuration.nix
          hmmod
        ];
      };

      kleene = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./hardware/lenovo.nix
          ./os/linux-nixos.nix
          ./users.nix
          ./configuration.nix
          hmmod
        ];
      };

      gates = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./os/windows-nixos.nix
          ./users.nix
          ./configuration.nix
          hmmod
        ];
      };

    };

    homeConfigurations = rec {

      jason = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/jason.nix ];
        extraSpecialArgs = { inherit pkgs; };
      };

      jason-no-desktop = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/jason.nix ];
        extraSpecialArgs = {
          inherit pkgs;
          desktop = false;
        };
      };

      luna = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/luna.nix ];
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
