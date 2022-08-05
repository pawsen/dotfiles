{ config, pkgs, lib, ... }:

{

  services.udev.extraRules = ''
    # Serial
    SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTR{idVendor}="1a86", ATTR{idProduct}="7523", GROUP="hwdevel"
  '';
}
