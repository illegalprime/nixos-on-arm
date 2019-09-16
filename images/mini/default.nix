{ config, pkgs, lib, ... }:
with lib;
{
  imports = [
    ../base
  ];

  # no GUI environment
  environment.noXlibs = mkDefault true;

  # don't build documentation
  documentation.info.enable = mkDefault false;
  documentation.man.enable = mkDefault false;

  # don't include a 'command not found' helper
  programs.command-not-found.enable = mkDefault false;

  # disable firewall (needs iptables)
  networking.firewall.enable = mkDefault false;

  # disable polkit
  security.polkit.enable = mkDefault false;

  # disable audit
  security.audit.enable = mkDefault false;

  # disable udisks
  services.udisks2.enable = mkDefault false;

  # disable containers
  boot.enableContainers = mkDefault false;

  # build less locales
  # This isn't perfect, but let's expect the user specifies an UTF-8 defaultLocale
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

  # Automatically log in at the virtual consoles.
  services.mingetty.autologinUser = mkDefault "root";

  # Allow the user to log in as root without a password.
  users.users.root.initialHashedPassword = mkOverride 999 "";

  # shrink boot partition to 25MB
  sdImage.bootSize = mkOverride 1100 25;

  # disable Grub by default, since no boards use it
  boot.loader.grub.enable = mkDefault false;
}
