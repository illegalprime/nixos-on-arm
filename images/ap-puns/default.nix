{ ... }:
{
  imports = [
    ../mini
    ./service.nix
  ];

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
}
