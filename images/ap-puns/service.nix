{ pkgs, ... }:
with builtins;
let
  puns = [
    "Pretty Fly for a WiFi"
    "Drop it Like It's Hot Spot"
    "LAN Before Time"
    "The WiFi of Khan"
    "It Burns When IP"
    "New England Clam Router"
    "Hide Your Kids Hide Your WiFi"
  ];

  iface = "wlan0";

  essids = concatStringsSep " " (map (name: ''-e "${name}"'') puns);

  # we have to do this because patchShebangs is broken
  wrapBash = cmd: "${pkgs.bash}/bin/bash -c '${cmd}'";
in
{
  boot.kernelPatches = [
    {
      name = "tun-module";
      patch = null;
      extraConfig = ''
        TUN m
      '';
    }
  ];

  systemd.services.ap-puns = {
    enable = true;
    description = "Blast Out WiFi Puns";
    path = with pkgs; [
      nettools
      iproute
      usbutils
      kmod
      utillinux.bin
      gawk
      procps
    ];
    wantedBy = ["multi-user.target"];
    serviceConfig = let
      start = wrapBash "${pkgs.aircrack-ng}/bin/airmon-ng start ${iface}";
      stop = wrapBash "${pkgs.aircrack-ng}/bin/airmon-ng stop ${iface}mon";
      run = "${pkgs.aircrack-ng}/bin/airbase-ng ${essids} ${iface}mon";
    in {
      Type = "simple";
      User = "root";
      Group = "root";
      Restart = "always";
      ExecStartPre = start;
      ExecStart = run;
      ExecStopPost = stop;
    };
    requires = ["systemd-networkd.service"];
    after = [
      "systemd-networkd.service"
      "sys-subsystem-net-devices-wlan0.device"
    ];
  };
}
