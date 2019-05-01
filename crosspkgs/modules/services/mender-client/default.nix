{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.mender;
in
{
   options = {
    services.mender = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          whether to enable the mender client to receive OTAs for your device
        '';
      };

      configuration = with types; {
        ArtifactVerifyKey = mkOption {
          default = null;
          type = nullOr path;
        };
        InventoryPollIntervalSeconds = mkOption {
          default = null;
          type = nullOr int;
        };
        RetryPollIntervalSeconds = mkOption {
          default = null;
          type = nullOr int;
        };
        RootfsPartA = mkOption {
          type = path;
        };
        RootfsPartB = mkOption {
          type = path;
        };
        # TODO: add assert that one of the following 2 are set
        Servers = mkOption {
          default = null;
          type = nullOr (listOf (submodule {
            ServerURL = mkOption {
              type = string;
            };
          }));
        };
        ServerURL = mkOption {
          default = null;
          type = nullOr string;
        };
        ServerCertificate = mkOption {
          default = null;
          type = nullOr path;
        };
        StateScriptRetryIntervalSeconds = mkOption {
          default = null;
          type = nullOr int;
        };
        StateScriptRetryTimeoutSeconds = mkOption {
          default = null;
          type = nullOr int;
        };
        StateScriptTimeoutSeconds = mkOption {
          default = null;
          type = nullOr int;
        };
        TenantToken = mkOption {
          default = null;
          type = nullOr string;
        };
        UpdateLogPath = mkOption {
          default = "/var/lib/mender/logs";
          type = path;
        };
        UpdatePollIntervalSeconds = mkOption {
          default = null;
          type = nullOr int;
        };
      };

      menderDeviceIdentity = mkOption {
        type = types.path;
        description = ''
          The script called by the Mender client to generate a unique device identity.
          It should exit with non 0 status code on errors.
          In this case the agent will discard any output the script may have produced.

          This script should output identity data in key=value format, one entry per line.
        '';
      };

      inventoryScripts = mkOption {
        type = types.listOf types.path;
        default = [];
        description = ''
          a list of script to be ran on the device and have their output sent
          and saved to the mender server

          this script should output info in key=value format, one per line
        '';
      };

      deviceType = mkOption {
        type = types.string;
        description = ''
          a unique string representing the device mender is running on
        '';
      };

      artifactName = mkOption {
        type = types.string;
        description = ''
          the name of the artifact as it shows up in mender,
          different images must have different names
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mender = {
      description = "Mender OTA update service";
      after = ["systemd-resolved.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "idle";
        User = "root";
        Group = "root";
        ExecStartPre = pkgs.writeScript "mender-setup" ''
          #! ${pkgs.runtimeShell}

          mkdir -p /usr/share/mender/identity
          ln -sf \
            ${cfg.menderDeviceIdentity} \
            /usr/share/mender/identity/mender-device-identity

          rm -rf /usr/share/mender/inventory
          mkdir -p /usr/share/mender/inventory
          ${builtins.concatStringsSep "\n" (map (p: ''
            ln -sf ${p} /usr/share/mender/inventory/
          '') cfg.inventoryScripts)}

          mkdir -p -m 0700 /data/mender /var/lib
          ln -sf /data/mender /var/lib/

          echo device_type=${lib.strings.escapeShellArg cfg.deviceType} \
            > /var/lib/mender/device_type
        '';
        ExecStart = "${pkgs.mender}/bin/mender -daemon";
        Restart = "on-abort";
      };
    };

    environment.etc.mender = {
      target = "mender/mender.conf";
      text = builtins.toJSON (lib.attrsets.filterAttrs
        (_: v: !builtins.isNull v) cfg.configuration);
    };

    environment.etc.artifact_info = {
      target = "mender/artifact_info";
      text = "artifact_name=${cfg.artifactName}";
    };
  };
}
