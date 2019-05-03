{ pkgs, config, lib, ... }:
{
  imports = [
    ./otg.nix
  ];

  # pick the right kernel
  boot.consoleLogLevel = lib.mkDefault 7;
  boot.kernelPackages = pkgs.linuxPackages_5_0;

  # set cross compiling
  nixpkgs.crossSystem = lib.systems.elaborate lib.systems.examples.raspberryPi;

  # disable other boot loaders
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # setup the boot loader & config.txt
  sdImage.populateBootCommands = let
    configTxt = pkgs.writeText "config.txt" ''
      # Prevent the firmware from smashing the framebuffer setup
      # done by the mainline kernel
      # when attempting to show low-voltage or overtemperature warnings.
      avoid_warnings=1

      # make debugging easier
      enable_uart=1

      ${lib.optionalString config.boot.otg.enable "dtoverlay=dwc2"}
    '';
  in with config.system.build; ''
    (
      cd ${pkgs.raspberrypifw}/share/raspberrypi/boot
      cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/boot/
    )

    cp ${pkgs.ubootRaspberryPiZero}/u-boot.bin boot/kernel.img

    cp ${configTxt} boot/config.txt

    ${installBootLoaderNative} ${toplevel} -d boot
  '';
}
