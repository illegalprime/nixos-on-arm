{ pkgs, ... }:
{
  imports = [
    ../mini
  ];

  boot.otg = {
    enable = true;
    module = "serial";
  };

  systemd.targets.getty.wants = [
    "serial-getty@ttyGS0.service"
  ];
}
