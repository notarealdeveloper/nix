
  ################
  ### <cachix> ###
  ################

  nix.settings = {

    trusted-users = [ "root" "user" "jason" ];

    substituters = [
      "https://cache.nixos.org"
      "https://${cacheName}.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "${cacheName}.cachix.org-1:lTWU+5FB7gvLg39/9EY1GDE3JV4HkRtprgxuKmkm/7g="
    ];

    post-build-hook = pkgs.writeShellScript "post-build-cachix.sh" ''
      set -euo pipefail
      # Nix sets OUT_PATHS as a space-separated list.
      # Send them to the daemon (fast, non-blocking wrt builds).
      if [ -n "''${OUT_PATHS-}" ]; then
        ${pkgs.cachix}/bin/cachix daemon push $OUT_PATHS || true
      fi
    '';

  };

  systemd.tmpfiles.rules = [ "d /etc/cachix 0750 root root -" ];

  systemd.services = {

    "cachix-daemon@${cacheName}" = {

      description = "Cachix daemon for ${cacheName}";

      wantedBy = [ "multi-user.target" ];

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        EnvironmentFile = "/etc/cachix/${cacheName}.env";
        ExecStart = "${pkgs.cachix}/bin/cachix daemon run ${cacheName}";

        Restart = "always";
        RestartSec = "10s";
      };

      # prevent "Start request repeated too quickly"
      startLimitIntervalSec = 0;  # disable rate limiting
    };

  };

  #################
  ### </cachix> ###
  #################

