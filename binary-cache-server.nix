# binary-cache-server.nix
{ config, lib, pkgs, ... }:
let
  cacheRoot = "/srv/nix-cache";
  secretKey = "/var/lib/nix-cache/secret-key";
in
{
  #### Create storage dir and key location with safe perms
  systemd.tmpfiles.rules = [
    "d ${cacheRoot} 0755 root root -"
    "d /var/lib/nix-cache 0700 root root -"
  ];

  #### One-shot: generate a signing key if missing
  systemd.services.nix-cache-generate-key = {
    description = "Generate Nix binary cache signing key if missing";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "gen-nix-cache-key" ''
        set -eu
        if [ ! -f "${secretKey}" ]; then
          ${pkgs.nix}/bin/nix key generate-secret --key-name my-cache-key > "${secretKey}.tmp"
          chmod 600 "${secretKey}.tmp"
          mv "${secretKey}.tmp" "${secretKey}"
          echo "[nix-cache] generated new signing key at ${secretKey}"
        fi
        echo "[nix-cache] public key (copy this to clients' trusted-public-keys):"
        ${pkgs.nix}/bin/nix key convert-secret-to-public < "${secretKey}"
      '';
      User = "root";
    };
  };

  #### Server machine signs store paths you copy into the cache
  nix.settings.secret-key-files = [ secretKey ];

  #### Nginx to serve the cache (plain HTTP; put behind TLS if needed)
  services.nginx = {
    enable = true;
    virtualHosts."_" = {
      # change to your hostname if you like
      root = cacheRoot;
      locations."/nix-cache/" = {
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };

  #### Handy: show a simple motd snippet with public key
  programs.motd.enable = true;
  programs.motd.text = ''
    --- Nix binary cache ---
    Push:   nix copy --to file://${cacheRoot} <store-paths>
    URL:    http://$HOSTNAME/nix-cache/
    PubKey: (also in journalctl -u nix-cache-generate-key)
  '';
}

