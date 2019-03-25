{ config, pkgs, lib, ... }:
with lib;
{
  imports = [
    ../base
  ];

  # try to get rid of unneeded stuff in the image
  environment.noXlibs = mkDefault true;
  documentation.info.enable = mkDefault false;
  documentation.man.enable = mkDefault false;
  programs.command-not-found.enable = mkDefault false;
  networking.firewall.enable = mkDefault false;

  # Automatically log in at the virtual consoles.
  services.mingetty.autologinUser = mkDefault "root";

  # Allow the user to log in as root without a password.
  users.users.root.initialHashedPassword = mkOverride 999 "";

  environment.systemPackages = with pkgs; [
    file
    vim
    man
    usbutils
    htop
  ];

  # networking
  networking.hostName = mkDefault "nixos-on-arm";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

  # SSH
  services.openssh.enable = true;
  services.openssh.permitRootLogin = mkDefault "yes";

  # DNS
  services.resolved.enable = true;
  services.resolved.dnssec = "false";

  # set a default root password
  users.mutableUsers = mkDefault false;
  users.users.root.password = mkDefault "toor";
}
