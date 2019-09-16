{
  iot = { config, lib, pkgs, ... }: {
    deployment = {
      targetHost = let
        ip = builtins.getEnv "IP";
      in if ip == ""
      then throw "Please set the IP environment variable to the target device."
      else ip;
    };

    imports = [
      <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
      <machine>
      <image>
    ];

    sdImage.enable = true;

    # NixOps needs SSH Access
    services.openssh.enable = true;
    services.openssh.permitRootLogin = lib.mkDefault "yes";
    users.users.root.initialPassword = lib.mkDefault "toor";
  };
}
