{ config, lib, pkgs, modulesPath, ... }:

let
  sdaDev = "/dev/disk/by-uuid/ee6b905c-09c0-4da2-8f5e-dd248cf906d1";
  espDev = "/dev/disk/by-uuid/D9F5-B698";
  btrfsDev = "/dev/mapper/enc";
  swapDev = "/dev/disk/by-uuid/10eb98bf-1258-44a7-ae95-93665fe3d7fc";

  subvolume = name: {
    device = btrfsDev;
    fsType = "btrfs";
    options = [ "subvol=${name}" "compress-force=zstd" "autodefrag" "noatime" ];
  };

in {

  boot.initrd.luks.devices."enc".device = sdaDev;
  fileSystems = {
    "/" = subvolume "@";
    "/home" = subvolume "@home";
    "/.subvols" = subvolume "";

    "/boot" = {
      device = espDev;
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = swapDev; } ];
  # you shouldn’t have to manually set boot.resumeDevice unless you’re using boot.initrd.systemd.enable
  #boot.resumeDevice = swapDev;
}
