{ ... }:
{
  imports = [
    ./hardware/leds
    ./hardware/burner
    ./services/mender-client
    ./cloudflare-dyndns
  ];

  nixpkgs.overlays = [
    (_: pkgs: import ../pkgs pkgs)
  ];
}
