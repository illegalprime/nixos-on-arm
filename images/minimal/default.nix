{ config, pkgs, lib, ... }:
{
  imports = [
    ../base
  ];

  # try to get rid of unneeded stuff in the image
  environment.noXlibs = true;
  documentation.info.enable = false;
  documentation.man.enable = false;
  programs.command-not-found.enable = false;
  networking.firewall.enable = false;

  # Automatically log in at the virtual consoles.
  services.mingetty.autologinUser = "root";

  # Allow the user to log in as root without a password.
  users.users.root.initialHashedPassword = "";

  environment.systemPackages = with pkgs; [
    file
    vim
    man
    usbutils
    htop
  ];

  # setup networking & SSH
  networking.hostName = "nixos-on-arm";
  networking.useNetworkd = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.resolved.enable = true;
  services.resolved.dnssec = "false";

  # set a default root password
  users.mutableUsers = false;
  users.users.root.password = "toor";
}
