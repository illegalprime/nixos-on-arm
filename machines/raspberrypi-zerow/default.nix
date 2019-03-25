{ pkgs, lib, ... }:
{
  imports = [
    ../raspberrypi-zero
  ];

  environment.systemPackages = with pkgs; [
    wirelesstools
    wpa_supplicant
    dhcp
  ];

  # when wlan0 is not configured dhcpcd takes 30 extra seconds
  # if you ever want to configure wlan0 just enable this again
  networking.dhcpcd.enable = lib.mkDefault false;

  hardware.firmware = with pkgs; [
    raspberrypiWirelessFirmware
  ];

  # TODO: bluetooth support
  # hardware.bluetooth.enable = true;
}
