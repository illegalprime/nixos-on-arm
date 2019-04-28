{ payload } @ args:
let
  nixos = import <nixpkgs/nixos> {
    configuration = { ... }: {
      imports = [
        <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
        <machine>
        (import ./configuration.nix args)
      ];
    };
  };
in
nixos.config.system.build.sdImage // {
  inherit (nixos) pkgs system config;
}
