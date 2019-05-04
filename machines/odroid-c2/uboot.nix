{ stdenv, fetchFromGitHub, openssl, buildUBoot, buildArmTrustedFirmware }:
let
  uboot_binary = "u-boot-dtb.bin";
  uboot = buildUBoot {
    defconfig = "odroid-c2_defconfig";
    extraMeta.platforms = [stdenv.hostPlatform.system];
    filesToInstall = [uboot_binary];
  };
  fiptool = buildArmTrustedFirmware {
    platform = "";
    installDir = "$out/bin";
    filesToInstall = ["tools/fip_create/fip_create"];
    extraMakeFlags = ["-C tools/fip_create"];
    version = "1.2";
    sha256 = "0pdh2lbrsw04hgihdyjrwp5vgj0b725b3da9vvssdz8v6rmgssf3";
    patches = [./patches/add_odroid_c2.patch];
  };
in
stdenv.mkDerivation {
  name = "signed-uboot-odroid-c2";

  nativeBuildInputs = [ fiptool ];

  buildCommand = ''
    fip_create \
        --bl30 ${./firmware/bl30.bin} \
        --bl301 ${./firmware/bl301.bin} \
        --bl31 ${./firmware/bl31.bin} \
        --bl33 ${uboot}/${uboot_binary} \
        fip.bin

    fip_create --dump fip.bin

    cat ${./firmware/bl2.package} fip.bin > boot_new.bin

    ${./tools/aml_encrypt_gxb} \
        --bootsig \
        --input boot_new.bin \
        --output ${uboot_binary}.tmp

    mkdir -p $out

    dd if=${uboot_binary}.tmp of=$out/${uboot_binary} bs=512 skip=96
  '';
}
