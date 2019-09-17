{ pkgs, ... }:
{
  imports = [
    ../mini
  ];

  # both UniFi and Oracle's JRE are closed-source, we allow that here:
  nixpkgs.config = {
    allowUnfree = true;
    oraclejdk.accept_license = true;
  };

  # enable the main service!
  services.unifi = {
    enable = true;

    # can't restore from backups made from newer versions
    # so we use a newer version also
    unifiPackage = pkgs.unifiStable;

    jrePackage = pkgs.jre8_headless.override {
      swingSupport = false; # don't need swing things
      guiSupport = false;   # don't need GUI things
    };

    mongodbPackage = pkgs.mongodb.override {
      jsEngine = "none";    # can't cross compile mozjs
      allocator = "system"; # can't cross compile gperftools
    };
  };

  # disable SSH, so the attack surface is smaller (for Guest Networks)
  services.openssh.enable = false;
}
