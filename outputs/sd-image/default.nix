let
  nixos = import <nixpkgs/nixos> {
    configuration = { ... }: {
      imports = [
        ./crosspkgs/modules # extra nixos modules
        <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
        <machine>
        <image>
      ];
    };
  };
in
nixos.config.system.build.sdImage // {
  inherit (nixos) pkgs system config;
}
