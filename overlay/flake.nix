{
  description = "Packages not yet in Nixpkgs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:

  let

    system = "x86_64-linux";

    overlay = (import ./src);

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ overlay ];
      config.allowUnfree = true;
    };

    lib = pkgs.lib;

    default = with pkgs; buildEnv {
      name = "overlay";
      ignoreCollisions = true;
      paths = builtins.attrValues derivations;
    };

    overlayNames = builtins.attrNames (import ./src {} pkgs);
    attrset      = pkgs.__splicedPackages;
    derivations  = lib.filterAttrs (k: v: lib.elem k overlayNames && lib.isDerivation v) attrset;
    packages = derivations // { inherit default; overlay = default; };

  in {
    packages.${system} = packages;

    overlays.default = overlay;
  };
}
