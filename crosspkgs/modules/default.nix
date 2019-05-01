{ ... }:
{
  imports = [
    ./hardware/leds
    ./hardware/burner
    ./services/mender-client
  ];

  nixpkgs.overlays = [
    (_: pkgs: import ../pkgs pkgs)
  ];
}
