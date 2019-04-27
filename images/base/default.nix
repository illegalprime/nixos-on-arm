{ config, pkgs, lib, ... }:
{
  # this value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "unstable"; # Did you read the comment?

  # use these overlays to work around cross compilation issues
  nixpkgs.overlays = [
    (self: super: {
      # don't want GUI libraries in our Erlang
      erlang = super.erlang.override { wxSupport = false; };
      # don't want a GUI in an embedded device
      gnupg = super.gnupg.override { guiSupport = false; };
      # python is broken here
      libnl = super.libnl.override { pythonSupport = false; };
      # don't need scripting support
      nmap  = super.nmap.override  { withLua = false; };
      # don't build polkit with gnome support
      polkit = super.polkit.override { withGnome = false; };
      # globally set node 6 as the node version
      nodejs = super.nodejs-6_x;
      # globally set node 6 as the node version
      nodePackages = super.nodePackages_6_x;
      # make a custom nodeEnv available
      nodeEnv = self.callPackage <nixpkgs/pkgs/development/node-packages/node-env.nix> {};
    })
  ];

  # use ARMv7 binary cache
  nix.binaryCaches = lib.mkForce [ "http://nixos-arm.dezgeg.me/channel" ];
  nix.binaryCachePublicKeys = [ "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%" ];
}
