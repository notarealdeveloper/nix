final: prev:

{
  sl2 = prev.callPackage ./sl2.nix { };

  noelf = prev.callPackage ./noelf.nix { };

  weatherspect = prev.callPackage ./weatherspect.nix { };

  #kdePackages.kdenlive = prev.kdePackages.kdenlive.overrideAttrs (old: {
  #  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.makeWrapper ];
  #  postInstall = (old.postInstall or "") + ''
  #    wrapProgram $out/bin/kdenlive \
  #      --prefix LADSPA_PATH : ${final.rnnoise-plugin}/lib/ladspa
  #  '';
  #});

}
