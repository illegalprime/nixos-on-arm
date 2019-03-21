{
  config = "armv7-unknown-linux-gnueabihf";
  system = "armv7l-linux";
  platform = {
    name = "beaglebone";
    kernelBaseConfig = "multi_v7_defconfig";
    kernelAutoModules = false;
    kernelTarget = "zImage";
    kernelMajor = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
    kernelArch = "arm";
    kernelDTB = true;
    kernelPreferBuiltin = true;
    kernelExtraConfig = ''
    '';
    gcc = {
      cpu = "cortex-a8";
      fpu = "neon";
    };
  };
  dtb = "am335x-bonegreen.dtb";
}
