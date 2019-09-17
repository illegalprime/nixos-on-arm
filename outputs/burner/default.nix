let
  to_burn = import <nixpkgs/nixos> {
    configuration = { pkgs, config, ... }: {
      imports = [
        <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
        <machine>
        <image>
      ];

      sdImage.enable = true;

      sdImage.processImageCommands = ''
        ( set -x
        # make bmap file
        ${pkgs.buildPackages.bmap-tools}/bin/bmaptool create $img \
          > $out/sd-image/${config.sdImage.imageName}.bmap

        # compress images
        ${pkgs.xz}/bin/xz -0 -z $img
        )
      '';
    };
  };

  burner = import <nixpkgs/nixos> {
    configuration = { ... }: let
      image = to_burn.config.system.build.sdImage;
      name = to_burn.config.sdImage.imageName;
    in {
      imports = [
        <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
        <machine>
        (import ./configuration.nix {
          payload = "${image}/sd-image/${name}.xz";
          bmap = "${image}/sd-image/${name}.bmap";
        })
      ];

      sdImage.enable = true;
    };
  };
in
burner.config.system.build.sdImage // {
  inherit (burner) pkgs system config;

  to_burn = to_burn.config.system.build.sdImage // {
    inherit (to_burn) pkgs system config;
  };
}
