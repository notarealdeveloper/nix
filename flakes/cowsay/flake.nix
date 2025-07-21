{
  description = "new and improved cowsay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    cowsay = {
      url = "github:notarealdeveloper/cowsay";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, cowsay }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    rec {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation rec {
        pname = "cowsay";
        version = "local";
        name = pname;
        src = cowsay;

        buildInputs = [ pkgs.perl ];

        buildPhase = ''
          echo "The cows don't need to be built, but thanks for asking."
        '';

        installPhase = ''
          make prefix=$out install
        '';
      };

      packages.x86_64-linux.cowsay = packages.x86_64-linux.default;
    };
}

