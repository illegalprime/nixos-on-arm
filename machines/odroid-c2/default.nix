{ pkgs, config, lib, ... }:
{
  # pick the right kernel
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # set cross compiling
  nixpkgs.crossSystem = lib.systems.elaborate {
    config = "aarch64-unknown-linux-gnu";
    platform = {
      name = "odroidc2";
      kernelMajor = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
      kernelBaseConfig = "defconfig";
      kernelArch = "arm64";
      kernelDTB = true;
      kernelAutoModules = true;
      kernelPreferBuiltin = true;
      kernelExtraConfig = ''
      '';
      kernelTarget = "Image";
      gcc = {
        arch = "armv8-a+crc";
        cpu = "cortex-a53";
      };
    };
  };

  # setup boot loader
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    dtbs = ["amlogic/meson-gxbb-odroidc2.dtb"];
  };
  sdImage.populateBootCommands = with config.system.build; ''
    ${installBootLoaderNative} ${toplevel} -d boot
  '';

  # setup uboot and secureboot in the MBR
  sdImage.processImageCommands = let
    uboot = pkgs.callPackage ./uboot.nix {};
  in ''
    dd if=${./secureboot/bl1.bin.hardkernel} of=$img conv=notrunc bs=1 count=442
    dd if=${./secureboot/bl1.bin.hardkernel} of=$img conv=notrunc bs=512 skip=1 seek=1
    dd if=${uboot}/u-boot-dtb.bin of=$img conv=notrunc bs=512 seek=97
  '';

  sdImage.bootSize = 40;
  sdImage.imageBaseName = "nixos-on-odroid-c2";
}
