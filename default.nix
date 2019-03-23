let
  nixos = import <nixpkgs/nixos> { configuration = <image>; };
in
nixos.config.system.build.sdImage // {
  inherit (nixos) pkgs system config;
}
