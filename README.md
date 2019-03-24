# NixOS on ARM

This is a WIP to _cross compile_ NixOS to run on ARM targets.

### Building

```
git clone --recursive https://github.com/illegalprime/nixos-on-arm.git
cd nixos-on-arm
```

This repository was reorganized to be able to build different boards if/when different ones are written. To build use:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/BOARD_TYPE \
  -I image=images/NIX_CONFIGURATION
```

#### BeagleBone Green

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/ap-puns
```

Currently `images/ap-puns` provides a service which will send out AP beacons of WiFi puns. This is a demo showing how one can build their own OS configured to do something out-of-the-box.

I think it's neat, much better than installing a generic Linux and configuring services yourself on the target.

#### Raspberry Pi Zero (W)

Both raspberry pi zeros are supported now! They come with cool OTG features:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/raspberrypi-zerow \
  -I image=images/rpi0-otg-serial
```

This will let you power and access the Raspberry Pi via serial through it's USB port.
Be sure to plug your micro USB cable in the data port, not the power port.


### Installing:

`bmap` is really handy here.

```
sudo bmaptool copy --nobmap result/sd-image/nixos-sd-image-*.img /dev/sdX
```

## What Works

1. BeagleBone Green (and now the Raspberry Pi Zero & Zero W!)
2. Networking & SSH
3. the BeagleBone's UART (Raspberry Pi Zero's serial port)
4. a bunch of standalone packages (vim, nmap, git, gcc, python, etc.)
5. all the `nix` utilities!
6. the USB port!

## What Doesn't Work

1. nix channels are also not packaged with the image for some reason do `nix-channel --update`
2. there are no binary caches, so you must build everything yourself :'(
3. there's still a good amount of x86 stuff that gets in there accidentally

## What Needs to Be Done

- [ ] patchShebangs needs to be fixed (https://github.com/NixOS/nixpkgs/issues/33956)
- [ ] libxml2Python needs a PR
- [ ] udisks needs a PR
- [ ] btrfs-utils needs a PR
- [ ] dhcp needs a PR
- [ ] nix: https://github.com/NixOS/nixpkgs/pull/58104
- [ ] nss: https://github.com/NixOS/nixpkgs/pull/58063
- [ ] fix sd-image resizing: https://github.com/NixOS/nixpkgs/pull/58059
- [ ] nilfs-utils: https://github.com/NixOS/nixpkgs/pull/58056
- [ ] volume_key: https://github.com/NixOS/nixpkgs/pull/58054
- [x] libatasmart: https://github.com/NixOS/nixpkgs/pull/58053
- [ ] polkit: https://github.com/NixOS/nixpkgs/pull/58052
- [ ] spidermonkey: https://github.com/NixOS/nixpkgs/pull/58049
- [ ] libndctl: https://github.com/NixOS/nixpkgs/pull/58047
- [x] gpgme: https://github.com/NixOS/nixpkgs/pull/58046
- [ ] inetutils: https://github.com/NixOS/nixpkgs/pull/57819
- [ ] gnupg: https://github.com/NixOS/nixpkgs/pull/57818
- [ ] libassuan: https://github.com/NixOS/nixpkgs/pull/57815
- [x] perlPackages.TermReadKey: https://github.com/NixOS/nixpkgs/pull/56019
- [ ] maybe a beaglebone target should be added to nix

### For Fun
- [ ] cross-compiling nodePackages still needs a PR!
- [ ] erlang: https://github.com/NixOS/nixpkgs/pull/58042
- [ ] autossh: https://github.com/NixOS/nixpkgs/pull/57825
- [ ] libmodbus: https://github.com/NixOS/nixpkgs/pull/57824
- [x] nmap: https://github.com/NixOS/nixpkgs/pull/57822
- [x] highlight: https://github.com/NixOS/nixpkgs/pull/57821
- [x] tree: https://github.com/NixOS/nixpkgs/pull/57820
- [x] devmem2: https://github.com/NixOS/nixpkgs/pull/57817
- [ ] nodejs: https://github.com/NixOS/nixpkgs/pull/57816
- [x] mg: https://github.com/NixOS/nixpkgs/pull/57814
- [ ] rust: https://github.com/NixOS/nixpkgs/pull/56540
- [x] cmake: https://github.com/NixOS/nixpkgs/pull/56021
