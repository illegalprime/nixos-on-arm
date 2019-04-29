{ lib, config, pkgs, ... }:
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

  # build & install boot loader
  sdImage.populateBootCommands = let
    kernel = beaglebone.platform.kernelTarget;
    init = "${config.system.build.toplevel}/init";
    root = ''/dev/mmcblk''${mmcdev}p2"'';
    uboot = pkgs.buildUBoot {
      defconfig = "am335x_evm_defconfig";
      extraMeta.platforms = [beaglebone.system];
      filesToInstall = ["MLO" "u-boot.img"];
      # NOTE: by default u-boot is built to read uEnv.txt from the SD card,
      # we modify it to attempt to read uEnv.txt from the eMMC as well.
      extraConfig = lib.strings.replaceStrings ["\n"] [" "] ''CONFIG_BOOTCOMMAND="
        if test ''${boot_fit} -eq 1; then
          run update_to_fit;
        fi;
        run findfdt;
        run init_console;
        run envboot;
        run bootcmd_mmc1;
        run bootcmd_legacy_mmc1;
        run envboot;
      "'';
    };
    uEnv = pkgs.writeText "uEnv.txt" ''
      bootdir=
      bootfile=${kernel}
      fdtfile=${beaglebone.dtb}
      loadaddr=0x80007fc0
      fdtaddr=0x80F80000
      loadfdt=fatload mmc ''${mmcdev}:1 ''${fdtaddr} ''${fdtfile}
      loaduimage=fatload mmc ''${mmcdev}:1 ''${loadaddr} ''${bootfile}
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
