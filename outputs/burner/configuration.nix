{ payload, bmap }:

{ config, pkgs, lib, ... }:
with lib.strings;
{
  imports = [
    ../../images/mini
  ];

  # don't need any networking things
  networking.dhcpcd.enable = false;
  networking.enableIPv6 = false;
  networking.firewall.enable = false;

  systemd.services.burn-image = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    description = "Burn Beagle Bone Image";
    path = with pkgs; [ bmap-tools xz ];
    environment = {
      inherit payload bmap;
      disk = config.hardware.burner.disk;
      leds = concatStringsSep " " config.hardware.leds;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${config.hardware.burner.preBurnScript}";
      ExecStart = "${pkgs.runtimeShell} ${./burn.sh}";
      ExecStartPost = "${pkgs.systemd}/bin/poweroff";
    };
  };
}
