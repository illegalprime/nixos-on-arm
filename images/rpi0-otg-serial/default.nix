{ pkgs, ... }:
{
  imports = [
    ../minimal
  ];

  boot.otg = {
    enable = true;
    module = "serial";
  };

  systemd.targets.getty.wants = [
    "serial-getty@ttyGS0.service"
  ];
}
