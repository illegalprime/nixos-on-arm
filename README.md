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
