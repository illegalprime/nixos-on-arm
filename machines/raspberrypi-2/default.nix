{ pkgs, config, lib, ... }:
{
  # pick the right kernel
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # set cross compiling
  nixpkgs.crossSystem = lib.systems.elaborate {
    config = "armv7l-unknown-linux-gnueabihf";
    platform = {
      name = "raspberrypi2";
      kernelMajor = "2.6";
      kernelBaseConfig = "multi_v7_defconfig";
      kernelArch = "arm";
      kernelDTB = true;
      kernelAutoModules = true;
      kernelPreferBuiltin = true;
      kernelTarget = "zImage";
      gcc = {
        cpu = "cortex-a7";
        fpu = "neon-vfpv4";
      };
    };
  };

  # setup boot loader
  boot.loader.raspberryPi = {
    enable = true;
    uboot.enable = true;
    version = 2;
  };
  sdImage.populateBootCommands = with config.system.build; ''
    ${installBootLoaderNative} ${toplevel} -d boot
  '';

  sdImage.bootSize = lib.mkOverride 1050 32;
}
