{ lib, ... }:
{
  imports = [
    ../ssh
  ];

  # we want space to store extra boot configurations (120MB)
  sdImage.bootSize = lib.mkOverride 900 120;
}
