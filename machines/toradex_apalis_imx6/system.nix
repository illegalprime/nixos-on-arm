with builtins;
{
  config = "armv7l-unknown-linux-gnueabihf";
  system = "armv7l-linux";
  platform = {
    name = "toradex_apalis_imx6";
    kernelBaseConfig = "imx_v6_v7_defconfig";
    kernelAutoModules = false;
    kernelTarget = "zImage";
    kernelMajor = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
    kernelArch = "arm";
    kernelDTB = true;
    kernelPreferBuiltin = true;
    kernelExtraConfig = ''
    '';
    gcc = {
      cpu = "cortex-a9";
      fpu = "neon";
    };
  };
  dtb = "imx6q-apalis-eval.dtb";
}
