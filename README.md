# NixOS on ARM [![Build Status](https://travis-ci.org/illegalprime/nixos-on-arm.svg?branch=master)](https://travis-ci.org/illegalprime/nixos-on-arm)

This is a WIP to _cross compile_ NixOS to run on ARM targets.

## Table of Contents

  * [Building](#building)
    * [Using Cachix](#using-cachix)
    * [A Note on Image Size](#a-note-on-image-size)
    * [BeagleBone Green](#beaglebone-green)
        * [UniFi Controller](#unifi-controller)
    * [Raspberry Pi Zero (W)](#raspberry-pi-zero-w)
    * [Raspberry Pi 2](#raspberry-pi-2)
    * [Raspberry Pi 3](#raspberry-pi-3)
    * [Odroid C2](#odroid-c2)
    * [Toradex Apalis IMX6 (Community)](#toradex-apalis-imx6-community)
  * [Burning to an SD Card](#burning-to-an-sd-card)
  * [Burning to the eMMC](#burning-to-the-emmc)
    * [Adding Burner Support to Your Board](#adding-burner-support-to-your-board)
  * [NixOps Deployments](#nixops-deployments)
  * [Debugging](#debugging)
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
git clone -b 0.7.0 --recursive --shallow-submodules https://github.com/illegalprime/nixos-on-arm.git
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

## Raspberry Pi 2

The Raspberry Pi 2 is a 32-bit quad core @ 900MHz ARMv7 board with 1GB of RAM.
You can build for the Raspberry Pi 2, and it works with NixOps!

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/raspberrypi-2 \
  -I image=images/nixops
```

## Raspberry Pi 3

The Raspberry Pi 3 is a 64-bit quad core @ 1.2GHz ARMv8 board with 1GB of RAM.
It also has built-in 802.11n WiFi, and 10/100 Ethernet port.
Bluetooth doesn't work on this platform yet.
You can build for the Raspberry Pi 3, and it works with NixOps!

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/raspberrypi-3 \
  -I image=images/nixops
```

## Odroid C2

This was a really interesting board to work on and a lot of help was taken from
[jumpnow/meta-odroid-c2](https://github.com/jumpnow/meta-odroid-c2/).
It's a good example of how to build u-boot, sign it, and couple it with vendor-specific boot loader code.
This is a pretty good reference implementation for secure-boot and 64-bit arm boards.
Build it with:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/odroid-c2 \
  -I image=images/ssh
```

I haven't implemented building an SD burner for this board yet,
but it should be straightforward to do and it will be implemented
once I buy an eMMC.

## Toradex Apalis IMX6 (Community)

Board configurations for this just landed thanks to @deadloko!
I do not own this board so I cannot test it on every release,
but it should be similar to the BeagleBone. Build it with:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/toradex_apalis_imx6 \
  -I image=images/mini
```

# Burning to an SD Card

`bmap` is really handy here (`nix-shell -p bmap-tools`).

```
sudo bmaptool copy --nobmap result/sd-image/*.img /dev/sdX
```

# Burning to the eMMC

When your image is all ironed out you might want to store it in a more permanent place on your board: the _eMMC_. This type of storage is great because it can't be easily dislodged like an SD card, but it's harder to access.

If you have an SD card port _and_ an eMMC you're in luck, this repository defines an output (a directory in `outputs`) that will build an SD card image that will boot and burn another image onto the eMMC. You specify the image you want burned with the usual `-I image=` option.

We now use `bmaptool` to burn the image over which is faster, has integrity checks, and makes sure to sync the file system.
We also compress the image so that it can be safely copied over to the burner image.

All you have to do is use the `burner` output:

```
nix build \
  -f outputs/burner \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/nixops
```

Burn the result to an SD card (see [Burning to an SD Card](#burning-to-an-sd-card)) and boot into it. If LEDs for this board were configured, you should see one of the following patterns:

1. Each LED lighting up one by one in sequence means the eMMC is being written to.
2. All LEDs on means the write has finished successfully, the board will soon be powered off.
3. All LEDs blinking slowly means an error has occurred during the writing process.

(note that on the BeagleBone you must hold the `USER` button down, plug in power, then let go to boot into your SD card if there's already a boot loader on the eMMC)

## Adding Burner Support to Your Board

If you're writing the definition for a board you might want to enable support for this feature, to do so just implement the options in the `crosspkgs/modules/hardware/burner` module, which at the time of writing consists of only a couple of options:

1. **hardware.burner.disk**: the path to `dd` the image into (the path of the eMMC device)
2. **hardware.burner.preBurnScript**: a script to run before `dd` is called

You may also define LEDs in the `crosspkgs/modules/hardware/leds` module, which the burner script will use to display its status.
LEDs are just names of directories in the `/sys/class/leds/` directory.

Take a look at the `beaglebone` image definition if you want a concrete example.

# NixOps Deployments

NixOps support is here! That means you can manage all your devices without re-flashing!

## The Setup

To start burn a base image onto an SD card (this image just contains SSH and a larger boot partition to store new configurations in):

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/nixops
```

Then boot it and add your SSH key because NixOps only supports SSH keys:

```bash
# copy over the key
ssh-copy-id root@IP_ADDRESS

# load your SSH keys into your environment
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
```

Finally, create a NixOps deployment for your devices
(`iot` can be changed to anything):

```
nixops create ./nixops.nix -d iot
```

## Deploying New Configurations

Now you're ready to update your board with some new configurations!
Just use `nixops deploy` with the `IP` environment variable set to the your device's
(here we deploy the `ap-puns` image over our original `nixops` image):

```
IP=YOUR_DEVICES_IP \
  nixops deploy \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/ap-puns \
  -d iot
```

If you have access to a serial connection, you can pick your generation on boot:

```
------------------------------------------------------------
1:      NixOS - Default
2:      NixOS - Configuration 2 (2019-09-16 14:23 - 19.09pre-git)
3:      NixOS - Configuration 1 (1970-01-01 01:32 - 19.09pre-git)
Enter choice:
```

Otherwise you can take out the SD card and manually edit the `/extlinux/extlinux.conf` file in the boot partition.
Replace `DEFAULT nixos-default` with `DEFAULT nixos-42` in that file to temporarily boot from the 42nd generation.

# Debugging

Sometimes when thing go wrong you need to test specific parts of the build,
this repository is organized so it's easy to do that.

Let's say `dhcp` was broken, you can build just that package with:

```
nix build -f . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/mini \
  pkgs.dhcp
```

Similarly you can drop into a shell to inspect the build process for `dhcp` like:

```
nix-shell --pure . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/mini \
  -A pkgs.dhcp
```

then you can just call `genericBuild` in the `nix-shell` and simulate building that package.

If you wanted to inspect the final configuration values and other stuff,
you can drop into a `repl`:

```
nix repl . \
  -I nixpkgs=nixpkgs \
  -I machine=machines/beaglebone \
  -I image=images/mini \
```

Then the variable `config` contains the system configuration.

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
- [ ] gcc contamination: https://github.com/NixOS/nixpkgs/pull/58606
- [ ] nix: https://github.com/NixOS/nixpkgs/pull/58104
- [ ] fix sd-image resizing: https://github.com/NixOS/nixpkgs/pull/58059
- [ ] nilfs-utils: https://github.com/NixOS/nixpkgs/pull/58056
- [ ] patchShebangs: https://github.com/NixOS/nixpkgs/issues/33956 (reverted)
- [x] ~use host shell: https://github.com/NixOS/nixpkgs/pull/58977~
- [x] ~nss: https://github.com/NixOS/nixpkgs/pull/58063~
- [x] ~volume_key: https://github.com/NixOS/nixpkgs/pull/58054~
- [x] ~perl uses host pwd: https://github.com/NixOS/nixpkgs/pull/58979~
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
