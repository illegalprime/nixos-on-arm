{ config, pkgs, ... }:
let
  beaglebone = import ./beaglebone.nix;
in
{
  imports = [
    ./nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix
  ];

  # this value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "unstable"; # Did you read the comment?

  nixpkgs.crossSystem = beaglebone;
  nixpkgs.overlays = [
    (self: super: {
      # don't want GUI libraries in our Erlang
      erlang = super.erlang.override { wxSupport = false; };
      # don't want a GUI in an embedded device
      gnupg = super.gnupg.override { guiSupport = false; };
      # python is broken here
      libnl = super.libnl.override { pythonSupport = false; };
      # don't need scripting support
      nmap  = super.nmap.override  { withLua = false; };
      # don't build polkit with gnome support
      polkit = super.polkit.override { withGnome = false; };
      # globally set node 6 as the node version
      nodejs = super.nodejs-6_x;
      # globally set node 6 as the node version
      nodePackages = super.nodePackages_6_x;
      # make a custom nodeEnv available
      nodeEnv = self.callPackage ./nixpkgs/pkgs/development/node-packages/node-env.nix {};
    })
  ];

  # try to get rid of unneeded stuff in the image
  environment.noXlibs = true;
  documentation.info.enable = false;
  documentation.man.enable = false;
  programs.command-not-found.enable = false;

  # Automatically log in at the virtual consoles.
  services.mingetty.autologinUser = "root";

  # Allow the user to log in as root without a password.
  users.users.root.initialHashedPassword = "";

  environment.systemPackages = with pkgs; [
    arp-scan
    file
    vim
    man
    nmap
  ];

  networking.hostName = "nixos-on-arm";
  networking.useNetworkd = true;
  networking.firewall.enable = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.resolved.enable = true;
  services.resolved.dnssec = "false";

  # we'll use u-boot, but this is good for now
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # set a default root password
  users.mutableUsers = false;
  users.users.root.password = "toor";

  sdImage.populateBootCommands = let
    kernel = beaglebone.platform.kernelTarget;
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
      mmc_args=setenv bootargs console=''${console} ''${optargs} root=/dev/mmcblk0p2 rootfstype=ext4 init=${config.system.build.toplevel}/init
    '';
  in ''
    cp ${uboot}/MLO boot/
    cp ${uboot}/u-boot.img boot/
    cp ${config.boot.kernelPackages.kernel}/${kernel} boot/
    cp ${config.boot.kernelPackages.kernel}/dtbs/${beaglebone.dtb} boot/
    cp ${uEnv} boot/uEnv.txt
  '';
}
