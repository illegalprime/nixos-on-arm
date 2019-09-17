{ config, pkgs, lib, ... }:
with lib;
{
  imports = [
    ../mini
  ];

  # networking
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

  # SSH
  services.openssh.enable = mkDefault true;
  services.openssh.permitRootLogin = mkDefault "yes";

  # DNS
  services.resolved.enable = true;
  services.resolved.dnssec = "false";

  # set a default root password
  users.users.root.initialPassword = lib.mkDefault "toor";
}
