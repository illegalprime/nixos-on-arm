{ config, pkgs, lib, ... }:
with lib;
{
  imports = [
    ../mini
  ];

  services.cloudflare-dyndns = {
    enable = true;
    authKeyPath = "/etc/cloudflare/auth_key";
    zone = "noip.com";
    records = [
      {
        type = "A";
        name = "hello.noip.com";
        content = "@ip@";
        proxied = false;
      }
    ];
  };
}
