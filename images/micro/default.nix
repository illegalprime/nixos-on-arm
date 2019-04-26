{ pkgs, config, lib, ... }:
with lib;
{
  imports = [
    ../mini
  ];

  # do not expand fs after first boot
  sdImage.expandFS = mkDefault false;

  # shrink boot partition to 8MB (with a bit better priority than default)
  sdImage.bootSize = mkOverride 999 8;
}
