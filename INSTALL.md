# Comments to install process



## Change from `https` to `ssh`

``` sh
git remote set-url origin git@github.com:pawsen/dotfiles
git remote -v
```

## BTRFS

Create partion table
``` sh
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart root 512MiB -8GiB
parted /dev/nvme0n1 -- mkpart swap linux-swap -8GiB 100%
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 3 esp on
```

Encrypt  with luks encryption layer, creating swap and making FAT32 boot filesystem
``` sh
cryptsetup --verify-passphrase -v luksFormat /dev/nvme0n1p1
cryptsetup open /dev/nvme0n1p1 enc

mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mkfs.fat -F 32 -n nixos-boot /dev/nvme0n1p3
```

Create subvolumes
``` sh
mkfs.btrfs /dev/mapper/enc
mount -t btrfs /dev/mapper/enc /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume snapshot -r /mnt/@ /mnt/@-blank

umount /mnt

mount -o subvol=@,compress=zstd,noatime,autodefrag /dev/mapper/enc /mnt
mkdir /mnt/home
mount -o subvol=@home,compress=zstd,noatime,autodefrag /dev/mapper/enc /mnt/home

mkdir /mnt/boot
mount /dev/diskp3 /mnt/boot
```
** The hardware generator dosn’t include btrfs mount options, so keep in mind to add them. **

## Install default system without flakes

If installation with flakes fails, then install default system and switch to
this configuration after a reboot

(overwrite the generated `configuration.nix` with the one from this repo or edit it. Remember to add a `user` and enable  `experimental-features = nix-command flakes`)
``` sh
nixos-generate-config –root /mnt
cp configuration.nix /mnt/etc/nixos/
nixos-install
reboot
```
