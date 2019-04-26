{ config, pkgs, lib, ... }:
with lib;
{
  imports = [
    ../mini
  ];

  # networking
  networking.hostName = mkDefault "nixos-on-arm";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

  # SSH
  services.openssh.enable = mkDefault true;
  services.openssh.permitRootLogin = mkDefault "yes";

  # DNS
  services.resolved.enable = true;
  services.resolved.dnssec = "false";

  # set a default root password
  users.mutableUsers = mkDefault false;
  users.users.root.password = mkDefault "toor";
}
