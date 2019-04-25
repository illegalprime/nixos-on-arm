{ pkgs, config, ... }:
{
  imports = [
    ../base
  ];

  # disable polkit
  security.polkit.enable = false;

  # disable audit
  security.audit.enable = false;

  # disable udisks
  services.udisks2.enable = false;

  # disable containers
  boot.enableContainers = false;

  # TODO:
  # system.replaceRuntimeDependencies = [{
  #   original = pkgs.buildPackages.bash;
  #   replacement = pkgs.bash;
  # }];

  # do not expand fs after first boot
  sdImage.expandFS = false;

  # shrink boot partition to 10MB
  sdImage.bootSize = 10;

  # no GUI environment
  environment.noXlibs = true;

  # don't build documentation
  documentation.info.enable = false;
  documentation.man.enable = false;

  # don't include a 'command not found' helper
  programs.command-not-found.enable = false;

  # This isn't perfect, but let's expect the user specifies an UTF-8 defaultLocale
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

  # don't build the firewall
  networking.firewall.enable = false;
}
