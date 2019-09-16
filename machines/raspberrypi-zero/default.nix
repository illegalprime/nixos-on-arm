{ pkgs, config, lib, ... }:
{
  imports = [
    ./otg.nix
  ];

  # pick the right kernel
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # set cross compiling
  nixpkgs.crossSystem = lib.systems.elaborate lib.systems.examples.raspberryPi;

  # setup the boot loader
  boot.loader.raspberryPi = {
    enable = true;
    uboot.enable = true;
    version = 0;
  };
  sdImage.populateBootCommands = with config.system.build; ''
    ${installBootLoaderNative} ${toplevel} -d boot
  '';
}
