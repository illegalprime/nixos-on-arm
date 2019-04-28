{ lib, ... }:
with lib;
{
  options.hardware.burner = {
    disk = mkOption {
      type = types.string;
      description = ''
        the path to the EMMC or block device to burn the image to
      '';
    };

    preBurnScript = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        any extra commands to run before burning
      '';
    };
  };
}
