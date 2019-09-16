{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.cloudflare-dyndns; in
{
  options.services.cloudflare-dyndns = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable periodically setting cloud flare DNS records
        based on this machine's external IP
      '';
    };

    zone = mkOption {
      type = types.str;
      example = "example.org";
      description = ''
        the cloudflare zone to run in, usually the domain name
      '';
    };

    authKeyPath = mkOption {
      type = types.path;
      description = ''
        path to a cloudflare API token with
        Zone.Zone and Zone.DNS permissions for all zones
      '';
    };

    records = mkOption {
      type = types.listOf types.attrs;
      example = [
        {
          type = "A";
          name = "home.example.org";
          proxied = false;
          content = "@ip@";
        }
      ];
      description = ''
        DNS records in JSON format to send to cloudflare,
        any instances of `@ip@` are replaced with your external IP
      '';
    };

    interval = mkOption {
      type = types.str;
      default = "5m";
      example = "1h";
      description = ''
        the interval on which to update cloudflare,
        represented as a systemd time span:
        https://www.freedesktop.org/software/systemd/man/systemd.time.html
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cloudflare-dyndns = {
      description = "CloudFlare DynDNS Updater";
      enable = true;

      script = "${./update.sh}";
      path = with pkgs; [ bash curl jq ];
      environment = {
        CF_AUTH_KEY = cfg.authKeyPath;
        CF_ZONE = cfg.zone;
        CF_RECORDS = pkgs.writeText
          "cf-records.json" (builtins.toJSON cfg.records);
      };

      serviceConfig.Type = "oneshot";
      requires = ["network-online.target"];
      after = ["network-online.service"];
    };

    systemd.timers.cloudflare-dyndns = {
      description = "Periodically Update CloudFlare DynDNS";
      enable = true;

      timerConfig.OnUnitActiveSec = cfg.interval;

      wantedBy = ["timers.target"];
    };
  };
}
