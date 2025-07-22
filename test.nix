pkgs: pkgs.python313.withPackages (ps:

  let

    jello = ps.callPackage ./jello.nix { inherit pkgs ps; };

  in

    with ps; [

    jello

  ])
