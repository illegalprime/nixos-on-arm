# NixOS on ARM

This is a WIP to _cross compile_ NixOS to run on ARM targets.

Building:

```
git clone --recursive https://github.com/illegalprime/nixos-on-arm.git
cd nixos-on-arm
nix-build nixpkgs/nixos -I nixos-config=configuration.nix -A config.system.build.sdImage
```

Installing:

```
sudo bmaptool copy --nobmap result/sd-image/nixos-sd-image-*.img /dev/sdX
```

## What Works

1. only the BeagleBone Green
2. Networking & SSH
3. the BeagleBone's UART
4. not much else has been tested

## What Doesn't Work

1. `nix` itself! (it contains references to x86 packages)
2. nix channels are also not packaged with the image for some reason
