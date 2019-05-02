{ pkgs, config, lib, ... }:
{
  # pick the right kernel
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # set cross compiling
  nixpkgs.crossSystem = lib.systems.elaborate {
    config = "armv7l-unknown-linux-gnueabihf";
    platform = {
      name = "raspberrypi2";
      kernelMajor = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
      kernelBaseConfig = "multi_v7_defconfig";
      kernelArch = "arm";
      kernelDTB = true;
      kernelAutoModules = true;
      kernelPreferBuiltin = true;
      kernelTarget = "zImage";
      kernelExtraConfig = ''
      '';
      gcc = {
        cpu = "cortex-a7";
        fpu = "neon-vfpv4";
      };
    };
  };

  # setup boot loader
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    uboot.enable = true;
    version = 2;
  };

  # TODO: extlinux-conf-builder.sh: line 123: cd: /nix/var/nix/profiles: No such file or directory
  # TODO: contamination:
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/loader/raspberrypi/uboot-builder.nix#L28
  # TODO: need different boot loader builders for host & build systems
  sdImage.populateBootCommands = with config.system.build; ''
    ${installBootLoader} ${toplevel} -d ./boot
  '';

  # TODO: don't load every dtb possible
  sdImage.bootSize = 64;
}
