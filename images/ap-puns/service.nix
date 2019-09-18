{ pkgs, ... }:
with builtins;
let
  puns = [
    # LAN
    "LAN Before Time"
    "Life in the fast LAN"
    "The Promised LAN"
    "House LANnister"
    "Silence of the LAN"
    "No LAN for the Wicked"
    "LAN of Milk and Honey"
    "The LAN of the Free"
    "Winter WonderLAN"
    "Wu Tang LAN"
    "Iron LAN"
    "SpiderLAN"
    
    # WiFi
    "The WiFi of Khan"
    "Pretty Fly for a WiFi"
    "Hide Your Kids Hide Your WiFi"
    "Tell my WiFi I love her"
    "No more Mr Wi-Fi"
    "I now prononouce you man and wifi"
    "They are taking the hobbits to WiFisengard!"
    "Thou Shalt Not Covet Thy Neighbor’s Wifi"
    "WiFi like an eagle"
    "I Believe Wi Can Fi"
    "Wi of the Figer"
    "Wi-Fry Chicken"
    "Your Wifi is in Another Castle"
    "Do Re Mi Fa So La Wi Fi"
    "You’re WiFired!"
    "My Wifu"
    
    # Router
    "New England Clam Router"
    "Martin Router King"
    "Routers of Rohan"
    "The Router Limits"
    "Go Go Router Rangers"
    "Brave Little Router"
    "Vladimir Routin"

    # Companies
    "Panic at the Cisco"
    "Abraham Linksys"
    "Linksys Lohan"
    "A Linksys to the Past"
    "For Whom the Belkin Tolls"
    
    # other
    "It Burns When IP"
    "Drop it Like It's Hot Spot"
    "Everyday I'm buffering"
    "Girls Gone Wireless"
    "Join My Bandwidth"
    "Winternet is Coming"
    "The Mad Ping"
    "Lord of the Ping"
    "That’s What She SSID"
    "Capture the Lag"
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
