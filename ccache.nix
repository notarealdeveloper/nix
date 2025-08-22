# ccache-global.nix
{ config, lib, pkgs, ... }:
{
  #### ccache package available on the host
  environment.systemPackages = [ pkgs.ccache ];

  #### A world-writable cache dir that is visible inside the Nix sandbox
  systemd.tmpfiles.rules = [
    "d /var/cache/ccache 0777 root root -"
  ];
  nix.settings.extra-sandbox-paths = [ "/var/cache/ccache" ];

  #### Wire nixpkgs to favor ccache when possible
  nixpkgs.config.ccache = {
    enable = true;
    baseDir = "/";                 # good default for stable hashing
    cacheDir = "/var/cache/ccache";
  };

  #### (Optional but effective) Wrap stdenv with ccache for *this* nixpkgs
  # This helps most packages you build from this system's nixpkgs input.
  nixpkgs.overlays = [
    (final: prev: {
      stdenv = prev.ccacheStdenv;
    })
  ];

  #### Runtime tuning for the host shell (nice for non-nix builds too)
  environment.variables = {
    CCACHE_DIR = "/var/cache/ccache";
    CCACHE_MAXSIZE = "20G";     # tune to taste
    CCACHE_COMPRESS = "1";
  };
}

