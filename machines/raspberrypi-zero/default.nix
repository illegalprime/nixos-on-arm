{ pkgs, config, lib, ... }:
let
  extlinux = <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix>;
  extlinux-conf-builder = import extlinux { pkgs = pkgs.buildPackages; };
in
with lib;
{
  imports = [
    ./otg.nix
  ];

  # pick the right kernel
  boot.consoleLogLevel = mkDefault 7;
  boot.kernelPackages = pkgs.linuxPackages_4_20;

  # enable free firmware
  hardware.enableRedistributableFirmware = true;

  # set cross compiling
  nixpkgs.crossSystem = systems.elaborate systems.examples.raspberryPi;

  # disable other boot loaders
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  # setup the boot loader & config.txt
  sdImage.populateBootCommands = let
    configTxt = pkgs.writeText "config.txt" ''
      # Prevent the firmware from smashing the framebuffer setup
      # done by the mainline kernel
      # when attempting to show low-voltage or overtemperature warnings.
      avoid_warnings=1

      # make debugging easier
      enable_uart=1

      ${optionalString config.boot.otg.enable "dtoverlay=dwc2"}
    '';
  in ''
    (
      cd ${pkgs.raspberrypifw}/share/raspberrypi/boot
      cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/boot/
    )
    cp ${pkgs.ubootRaspberryPiZero}/u-boot.bin boot/kernel.img
    cp ${configTxt} boot/config.txt
    ${extlinux-conf-builder} -t 1 \
      -c ${config.system.build.toplevel} \
      -d ./boot
  '';
}
