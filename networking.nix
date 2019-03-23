{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aircrack-ng
    wpa_supplicant
    dhcp
  ];

  boot.kernelPatches = [
    {
      name = "networking";
      patch = null;
      extraConfig = ''
        IP_NF_IPTABLES m

        RTL8187 m

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
