{ pkgs, ... }:
{
  imports = [
    ../raspberrypi-zero
  ];

  environment.systemPackages = with pkgs; [
    wirelesstools
    wpa_supplicant
    dhcp
  ];

  hardware.firmware = with pkgs; [
    raspberrypiWirelessFirmware
  ];

  # hardware.bluetooth.enable = true;
}
