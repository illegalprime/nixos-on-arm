{ config, pkgs, ... }:
let
  toradex_apalis_imx6 = import ./system.nix;
in
{
  # specify the system we're compiling to
  nixpkgs.crossSystem = toradex_apalis_imx6;

  # enable free firmware
  hardware.enableRedistributableFirmware = false;

  # specify a good kernel version
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # do our own boot-loader
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  # build & install boot loader
  sdImage.populateBootCommands = let
    kernel = toradex_apalis_imx6.platform.kernelTarget;
    init = "${config.system.build.toplevel}/init";
    root = "/dev/mmcblk2p2";
    uboot = pkgs.buildUBoot {
      defconfig = "apalis_imx6_defconfig";
      extraMeta.platforms = [toradex_apalis_imx6.system];
      filesToInstall = ["SPL" "u-boot.img"];
    };
    uEnv = pkgs.writeText "uEnv.txt" ''
      bootdir=
      bootcmd=run uenvcmd;
      bootfile=${kernel}
      fdtfile=${toradex_apalis_imx6.dtb}
      loadaddr=0x11000000
      fdtaddr=0x12000000
      loadfdt=load mmc 0:1 ''${fdtaddr} ''${fdtfile}
      loaduimage=load mmc 0:1 ''${loadaddr} ''${bootfile}
      uenvcmd=mmc rescan; run loaduimage; run loadfdt; run fdtboot
      fdtboot=run mmc_args; bootz ''${loadaddr} - ''${fdtaddr}
      mmc_args=setenv bootargs console=''${console} ''${optargs} root=${root} rootfstype=ext4 init=${init}
    '';

    # Populate result/nix-support/tezi folder for ToradexEasyInstaller.
    populateToradexTezi = ''
    mkdir -p $out/nix-support/tezi/
    cp ${uboot}/SPL $out/nix-support/tezi/
    cp ${uboot}/u-boot.img $out/nix-support/tezi/
    cp ${config.boot.kernelPackages.kernel}/${kernel} $out/nix-support/tezi/
    cp ${config.boot.kernelPackages.kernel}/dtbs/${toradex_apalis_imx6.dtb} $out/nix-support/tezi/
    cp ${uEnv} $out/nix-support/tezi/uEnv.txt
    '';

  in ''
    ${populateToradexTezi}
    cp ${uboot}/SPL boot/
    cp ${uboot}/u-boot.img boot/
    cp ${config.boot.kernelPackages.kernel}/${kernel} boot/
    cp ${config.boot.kernelPackages.kernel}/dtbs/${toradex_apalis_imx6.dtb} boot/
    cp ${uEnv} boot/uEnv.txt
  '';
}
