{ lib, ... }:
with lib;
{
  options = {
    hardware.leds = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        a list of user controllable LEDs as found under /sys/class/leds
      '';
    };
  };
}
