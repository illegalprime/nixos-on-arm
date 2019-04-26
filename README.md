# NixOS on ARM [![Build Status](https://travis-ci.org/illegalprime/nixos-on-arm.svg?branch=master)](https://travis-ci.org/illegalprime/nixos-on-arm)

This is a WIP to _cross compile_ NixOS to run on ARM targets.

## Table of Contents

  * [Building](#building)
    * [Using Cachix](#using-cachix)
    * [A Note on Image Size](#a-note-on-image-size)
    * [BeagleBone Green](#beaglebone-green)
        * [UniFi Controller](#unifi-controller)
    * [Raspberry Pi Zero (W)](#raspberry-pi-zero-w)
    * [Toradex Apalis IMX6 (Community)](#toradex-apalis-imx6-community)
  * [Installing](#installing)
  * [Images Overview](#images-overview)
    * [Image Templates](#image-templates)
    * [Demos](#demos)
  * [Contributing](#contributing)
  * [Current State](#current-state)
    * [What Works](#what-works)
    * [What Doesn't Work](#what-doesnt-work)
    * [What Needs to Be Done](#what-needs-to-be-done)
        * [For Fun](#for-fun)

# Building

Clone the latest release:

```
git clone -b 0.5.0 --recursive --shallow-submodules https://github.com/illegalprime/nixos-on-arm.git
cd nixos-on-arm
```

This repository was reorganized to be able to build different boards if/when different ones are written. To build use:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/BOARD_TYPE \
  -I image=images/NIX_CONFIGURATION
```

### Using Cachix

This repository uses Travis to keep a fresh cachix cache, which you can use to speed up your builds:

```bash
# install cachix if you haven't already
nix-env -iA cachix -f https://cachix.org/api/v1/install
# use this cache when building
cachix use cross-armed
```

### A Note on Image Size

Many things affect image size and recently a lot of work has been done to minimize it:

1. splitting gcc libs into different output (https://github.com/NixOS/nixpkgs/pull/58606)
2. strip in cross builds (https://github.com/NixOS/nixpkgs/pull/59787) (https://github.com/NixOS/nixpkgs/issues/21667#issuecomment-271083104) (https://github.com/NixOS/nixpkgs/pull/15339)

A lot of things still have to be done to remove x86 remnants from accidentally getting into the image (like updating patchShebangs https://github.com/NixOS/nixpkgs/issues/33956), and contaminants can be checked by running `./check-contamination.sh result`.

See the [Images Overview](#images-overview) for a breakdown of image sizes.

## BeagleBone Green

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/ap-puns
```

Currently `images/ap-puns` provides a service which will send out AP beacons of WiFi puns. This is a demo showing how one can build their own OS configured to do something out-of-the-box.
(NOTE you need a USB WiFi dongle, I included kernel modules for the Ralink chipset)

I think it's neat, much better than installing a generic Linux and configuring services yourself on the target.

### UniFi Controller

You can build an image which starts a UniFi controller so you don't have to buy one!
This is useful if you have a UniFi router or AP, which uses this controller for extra memory and processing power.
Currently tested with the beaglebone:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/unifi
```

Since the beaglebone is slow, it could take a while to boot.

## Raspberry Pi Zero (W)

Both raspberry pi zeros are supported now! They come with cool OTG features:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/raspberrypi-zerow \
  -I image=images/rpi0-otg-serial
```

This will let you power and access the Raspberry Pi via serial through it's USB port.
Be sure to plug your micro USB cable in the data port, not the power port.

The first boot takes longer since it resizes the SD card to fill its entire space, so the serial device (usually `/dev/ttyACM0`) might take longer to show up.

You can also build an image with turns the USB port into an Ethernet adapter, letting you SSH into the raspberry pi by plugging it into your computer:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/raspberrypi-zerow \
  -I image=images/rpi0-otg-ether
```

copy it to an SD card ('Installing' section), plug it in, wait for it to boot and to show up as an Ethernet device, then just:

```
ssh root@10.0.3.1
```

## Toradex Apalis IMX6 (Community)

Board configurations for this just landed thanks to @deadloko!
I do not own this board so I cannot test it on every release,
but it should be similar to the BeagleBone. Build it with:

```
nix-build . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/toradex_apalis_imx6 \
  -I image=images/mini
```

# Installing

`bmap` is really handy here.

```
sudo bmaptool copy --nobmap result/sd-image/nixos-sd-image-*.img /dev/sdX
```

# Images Overview

Some images are full-fledged demos with a use case, and others are just templates for you to build your own images with.

## Image Templates

(the size is based off BeagleBone builds)

| Name  | Size  | Description                                                                                                  |
| :---: | :---: |--------------------------------------------------------------------------------------------------------------|
| base  | > 2GB | the smallest changes to the nix configuration needed to cross-build                                          |
| mini  | 584MB | smaller than base, with most non-critical services turned off, like `polkit`, `udisks`, `containers`, etc.   |
| micro | 564MB | smaller than mini, meant to be flashed once and not updated directly (but updated by flashing another image) |
| ssh   | 584MB | based off mini but with SSH access                                                                           |

The `micro` image isn't very micro right now, but hopefully it will be soon.
It's meant to not have any nix utilities or the daemon, a smaller kernel, and generally the bare minimum needed to run on the board.
Currently, it's not very different from the `mini` image.

## Demos

1. **ap-puns** use `aircrack-ng` to send out fake AP Beacons with pun names
2. **rpi0-otg-ether** run a Raspberry Pi 0 as an Ethernet Adapter with SSH in OTG mode
3. **rpi0-otg-serial** run a Raspberry Pi 0 as a serial adapter
4. **unifi** boot into a UniFi controller that manages UniFi APs

# Contributing

For inspiration either look at the currently open issues or [What Needs to Be Done](#what-needs-to-be-done).
Otherwise just try it out and put in fixes as you find them, ultimately all fixes that end up here will
be sent upstream so all of `nixpkgs` can benefit.

Alternatively, send it directly upstream and link the commit in an issue, it will possibly be cherry-picked here.

# Current State

## What Works

1. BeagleBone Green (and now the Raspberry Pi Zero & Zero W!)
2. Networking & SSH
3. the BeagleBone's UART (Raspberry Pi Zero's serial port)
4. a bunch of standalone packages (vim, nmap, git, gcc, python, etc.)
5. all the `nix` utilities!
6. the USB port!

## What Doesn't Work

1. nix channels are also not packaged with the image for some reason do `nix-channel --update`
2. there's still a good amount of x86 stuff that gets in there accidentally
3. bluetooth on the raspberry pi zeros (and likely on all the other platforms)

## What Needs to Be Done

- [ ] libxml2Python needs a PR
- [ ] udisks needs a PR
- [ ] btrfs-utils needs a PR
- [ ] use host awk in vim build (need to make PR)
- [ ] use host coreutils in perl derivation (need to make a PR)
- [ ] use host shell in nixos-tools (need to make a PR)
- [ ] gcc contamination: https://github.com/NixOS/nixpkgs/pull/58606
- [ ] nix: https://github.com/NixOS/nixpkgs/pull/58104
- [ ] nss: https://github.com/NixOS/nixpkgs/pull/58063
- [ ] fix sd-image resizing: https://github.com/NixOS/nixpkgs/pull/58059
- [ ] nilfs-utils: https://github.com/NixOS/nixpkgs/pull/58056
- [ ] volume_key: https://github.com/NixOS/nixpkgs/pull/58054
- [ ] patchShebangs: https://github.com/NixOS/nixpkgs/issues/33956 (reverted)
- [x] ~strip cross built bins: https://github.com/NixOS/nixpkgs/pull/59787~
- [x] ~libassuan: https://github.com/NixOS/nixpkgs/pull/57815~
- [x] ~dhcp: https://github.com/NixOS/nixpkgs/pull/58305~
- [x] ~writeShellScriptBin: https://github.com/NixOS/nixpkgs/pull/58977~
- [x] ~polkit: https://github.com/NixOS/nixpkgs/pull/58052~
- [x] ~spidermonkey: https://github.com/NixOS/nixpkgs/pull/58049~
- [x] ~inetutils: https://github.com/NixOS/nixpkgs/pull/57819~
- [x] ~libatasmart: https://github.com/NixOS/nixpkgs/pull/58053~
- [x] ~libndctl: https://github.com/NixOS/nixpkgs/pull/58047~
- [x] ~gpgme: https://github.com/NixOS/nixpkgs/pull/58046~
- [x] ~gnupg: https://github.com/NixOS/nixpkgs/pull/57818~
- [x] ~perlPackages.TermReadKey: https://github.com/NixOS/nixpkgs/pull/56019~
~
### For Fun

- [ ] cross-compiling nodePackages still needs a PR!
- [ ] erlang: https://github.com/NixOS/nixpkgs/pull/58042
- [ ] nodejs: https://github.com/NixOS/nixpkgs/pull/57816
- [x] ~autossh: https://github.com/NixOS/nixpkgs/pull/57825~
- [x] ~libmodbus: https://github.com/NixOS/nixpkgs/pull/57824~
- [x] ~nmap: https://github.com/NixOS/nixpkgs/pull/57822~
- [x] ~highlight: https://github.com/NixOS/nixpkgs/pull/57821~
- [x] ~tree: https://github.com/NixOS/nixpkgs/pull/57820~
- [x] ~devmem2: https://github.com/NixOS/nixpkgs/pull/57817~
- [x] ~mg: https://github.com/NixOS/nixpkgs/pull/57814~
- [x] ~rust: https://github.com/NixOS/nixpkgs/pull/56540~
- [x] ~cmake: https://github.com/NixOS/nixpkgs/pull/56021~
