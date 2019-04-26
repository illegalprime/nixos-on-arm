{ pkgs, ... }:
{
  imports = [
    ../mini
    ./service.nix
  ];

  #
  # NOTE: this is built to work with the ralink 2870 chipset.
  # https://www.amazon.com/150Mbps-Adapter-LOTEKOO-Wireless-Raspberry/dp/B06Y2HKT75
  # to use your own WiFi dongle, add its kernel modules and firmware
  #

  # add the WiFi kernel modules
  boot.kernelPatches = [
    {
      name = "ralink-chipset";
      patch = null;
      extraConfig = ''
        WLAN_VENDOR_RALINK y
        RT2X00 m
        RT2800USB m
        RT2800USB_RT35XX y
        RT2800USB_RT53XX y
        RT2800_LIB m
        RT2X00_LIB_USB m
        RT2X00_LIB m
        RT2X00_LIB_FIRMWARE y
        RT2X00_LIB_CRYPTO y
        RT2X00_LIB_LEDS y
      '';
    }
  ];

  # add the WiFi firmware
  hardware.firmware = [
    (pkgs.runCommand "rt2870" {} ''
      mkdir -p $out/lib/firmware
      cp ${pkgs.firmwareLinuxNonfree}/lib/firmware/rt2870.bin $out/lib/firmware/
    '')
  ];
}
