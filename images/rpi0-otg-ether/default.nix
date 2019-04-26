{ pkgs, ... }:
{
  imports = [
    ../ssh
  ];

  boot.otg = {
    enable = true;
    module = "ether";
  };

  networking.dhcpcd.denyInterfaces = ["usb0"];

  services.dhcpd4 = {
    enable = true;
    interfaces = ["usb0"];
    extraConfig = ''
      option domain-name "nixos";
      option domain-name-servers 8.8.8.8, 8.8.4.4;
      subnet 10.0.3.0 netmask 255.255.255.0 {
        range 10.0.3.100 10.0.3.200;
        option subnet-mask 255.255.255.0;
        option broadcast-address 10.0.3.255;
      }
    '';
  };

  networking.interfaces.usb0.ipv4.addresses = [
    {
      address = "10.0.3.1";
      prefixLength = 24;
    }
  ];
}
