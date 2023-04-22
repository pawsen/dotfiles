{ config, lib, pkgs, modulesPath, ... }:

let
  sdaDev = "/dev/disk/by-uuid/9558252a-7d70-41e9-9d6f-bb0738fd601a";
  espDev = "/dev/disk/by-uuid/E72D-0127";
  btrfsDev = "/dev/mapper/enc";
  swapDev = "/dev/disk/by-uuid/5f4aede7-270e-4715-ab43-3c8b09339a70";

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
}
