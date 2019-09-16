{ lib, config, pkgs, ... }:
{
  # specify the system we're compiling to
  nixpkgs.crossSystem = lib.systems.elaborate {
    config = "armv7l-unknown-linux-gnueabihf";
    platform = {
      name = "beaglebone";
      kernelBaseConfig = "multi_v7_defconfig";
      kernelAutoModules = false;
      kernelTarget = "zImage";
      kernelMajor = "2.6";
      kernelArch = "arm";
      kernelDTB = true;
      kernelPreferBuiltin = true;
      gcc = {
        cpu = "cortex-a8";
        fpu = "neon";
      };
    };
  };

  # specify a good kernel version
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # enable the UART connection
  boot.kernelParams = ["console=ttyO0,115200n8"];

  #
  # Bootloader (UBoot, extlinux)
  #
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    dtbs = ["am335x-bonegreen.dtb"];
  };
  sdImage.populateBootCommands = let
    uboot = pkgs.buildUBoot {
      defconfig = "am335x_evm_defconfig";
      extraMeta.platforms = ["armv7l-linux"];
      filesToInstall = ["MLO" "u-boot.img"];
    };
  in with config.system.build; ''
    cp ${uboot}/MLO boot/
    cp ${uboot}/u-boot.img boot/
    ${installBootLoaderNative} ${toplevel} -d boot
  '';

  #
  # LEDs (burner images use this for instance)
  #
  hardware.leds = [
	  "beaglebone:green:heartbeat"
	  "beaglebone:green:mmc0"
	  "beaglebone:green:usr2"
	  "beaglebone:green:usr3"
  ];

  #
  # Burner Support
  #
  hardware.burner = {
    disk = "/dev/mmcblk1";

    # erase read only boot disk
    preBurnScript = pkgs.writeScript "beaglebone-pre-burn" ''
      #! ${pkgs.runtimeShell}
      set -euxo pipefail

      echo 0 > /sys/block/mmcblk1boot0/force_ro
      echo 0 > /sys/block/mmcblk1boot1/force_ro

      dd if=/dev/zero of=/dev/mmcblk1boot0 bs=512 count=4096
      dd if=/dev/zero of=/dev/mmcblk1boot1 bs=512 count=4096
    '';
  };
}
