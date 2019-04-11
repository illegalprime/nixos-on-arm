{ config, pkgs, ... }:
let
  beaglebone = import ./system.nix;
in
{
  # specify the system we're compiling to
  nixpkgs.crossSystem = beaglebone;

  # specify a good kernel version
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # do our own boot-loader
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  # enable some basic firmware
  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];

  # build & install boot loader
  sdImage.populateBootCommands = let
    kernel = beaglebone.platform.kernelTarget;
    init = "${config.system.build.toplevel}/init";
    root = "/dev/mmcblk0p2";
    uboot = pkgs.buildUBoot {
      defconfig = "am335x_evm_defconfig";
      extraMeta.platforms = [beaglebone.system];
      filesToInstall = ["MLO" "u-boot.img"];
    };
    uEnv = pkgs.writeText "uEnv.txt" ''
      bootdir=
      bootfile=${kernel}
      fdtfile=${beaglebone.dtb}
      loadaddr=0x80007fc0
      fdtaddr=0x80F80000
      loadfdt=fatload mmc 0:1 ''${fdtaddr} ''${fdtfile}
      loaduimage=fatload mmc 0:1 ''${loadaddr} ''${bootfile}
      uenvcmd=mmc rescan; run loaduimage; run loadfdt; run fdtboot
      fdtboot=run mmc_args; run mmcargs; bootz ''${loadaddr} - ''${fdtaddr}
      mmc_args=setenv bootargs console=''${console} ''${optargs} root=${root} rootfstype=ext4 init=${init}
    '';
  in ''
    cp ${uboot}/MLO boot/
    cp ${uboot}/u-boot.img boot/
    cp ${config.boot.kernelPackages.kernel}/${kernel} boot/
    cp ${config.boot.kernelPackages.kernel}/dtbs/${beaglebone.dtb} boot/
    cp ${uEnv} boot/uEnv.txt
  '';
}
