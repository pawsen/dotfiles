{ config, lib, pkgs, modulesPath, ... }:

let
  sdaDev = "/dev/disk/by-uuid/ee6b905c-09c0-4da2-8f5e-dd248cf906d1";
  espDev = "/dev/disk/by-uuid/D1CA-CB31";
  btrfsDev = "/dev/disk/by-uuid/33adb609-350d-435e-8918-8da0188cdfc6";
  swapDev = "/dev/disk/by-uuid/a1e0ad52-c602-4440-9a21-0c5a8c7df839";

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
