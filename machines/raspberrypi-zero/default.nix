{ pkgs, config, lib, ... }:
let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      pkgs = pkgs.buildPackages;
    };

  otg_modules = {
    "serial" = {
      module = "g_serial";
      config = "USB_G_SERIAL m";
      # USB_F_SERIAL m
      # USB_F_OBEX m
      # USB_F_ACM m
    };
    "ether" = {
      module = "g_ether";
      config = "USB_ETH m";
    };
    # "mass_storage" = {};
    # "midi" = {};
    # "audio" = {};
    # "hid" = {};
    # "acm_ms" = {};
    # "cdc" = {};
    # "multi" = {};
    # "webcam" = {};
    # "printer" = {};
    "zero" = {
      module = "g_zero";
      config = "USB_ZERO m";
    };
  };
in
with lib;
with builtins;
{
  options = {
    boot.otg = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          enable USB OTG, let your raspberry pi
          act as a USB device.
        '';
      };
      module = mkOption {
        type = types.enum (attrNames otg_modules);
        default = "zero";
        example = "ether";
        description = ''
          the OTG module to load
        '';
      };
    };
  };
  config = {
    # pick the right kernel
    boot.consoleLogLevel = lib.mkDefault 7;
    boot.kernelPackages = pkgs.linuxPackages_4_20;

    # enable free firmware
    hardware.enableRedistributableFirmware = true;

    # set cross compiling
    nixpkgs.crossSystem = lib.systems.elaborate
      lib.systems.examples.raspberryPi;

    # add otg modules if necessary
    boot.kernelPatches = [
      (mkIf config.boot.otg.enable {
        name = "usb-otg";
        patch = null;
        extraConfig = ''
          USB_GADGET y
          USB_DWC2 m
          USB_DWC2_DUAL_ROLE y
          ${otg_modules.${config.boot.otg.module}.config}
        '';
      })
    ];
    boot.kernelModules = mkIf config.boot.otg.enable [
      "dwc2" "${otg_modules.${config.boot.otg.module}.module}"
    ];

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
  };
}
