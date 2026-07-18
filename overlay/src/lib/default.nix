final: prev:

  (import ./python final prev)
  //
  (let
    unsupportedHwlocFlags = [
      "--enable-netloc"
    ];
  in {
    hwloc = prev.hwloc.overrideAttrs (old: {
      configureFlags =
        builtins.filter
          (flag: !(builtins.elem flag unsupportedHwlocFlags))
          (old.configureFlags or []);
    });
  })
