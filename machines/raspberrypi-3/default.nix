{ pkgs, config, lib, ... }:
{
  # pick the right kernel
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # set cross compiling
  nixpkgs.crossSystem = lib.systems.elaborate {
    config = "aarch64-unknown-linux-gnu";
    platform = {
      name = "raspberrypi3";
      kernelMajor = "2.6";
      kernelBaseConfig = "defconfig";
      kernelArch = "arm64";
      kernelDTB = true;
      kernelAutoModules = true;
      kernelPreferBuiltin = true;
      kernelTarget = "Image";
      gcc = {
        cpu = "cortex-a53+crypto";
        arch = "armv8-a+crc";
      };
    };
  };

  # setup boot loader
  boot.loader.raspberryPi = {
    enable = true;
    uboot.enable = true;
    version = 3;
  };
  sdImage.populateBootCommands = with config.system.build; ''
    ${installBootLoaderNative} ${toplevel} -d boot
  '';

  # WiFi support
  hardware.firmware = with pkgs; [
    raspberrypiWirelessFirmware
  ];
  environment.systemPackages = with pkgs; [
    wirelesstools
    wpa_supplicant
    dhcp
  ];

  sdImage.bootSize = lib.mkOverride 1050 64;
}
