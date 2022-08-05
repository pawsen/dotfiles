# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x1/6th-gen>
    (modulesPath + "/installer/scan/not-detected.nix")
    ./filesystem.nix
    ./udev.nix
    ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.timeout = 5;
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    # Set specific kernel version. If not set, latest will be used (specified in
    # default.nix)
    # kernelPackages = pkgs.linuxPackages_5_14;
  };

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Modules
  modules.hardware = {
    audio.enable = true;
    fs = {
      enable = true;
      ssd.enable = true;
    };
  };

  # power settings
  # environment.systemPackages = with pkgs; [ tlp powertop s-tui i7z ];
  environment.systemPackages = with pkgs; [ tlp i7z ];
  # powerManagement.powertop.enable = true;
  # There are two common cpufreq drivers: intel_pstate and acpi-cpufreq. With a
  # Sandy bridge CPU the default is intel_pstate. They differs in the Governors
  # we can choose and how the Governors work(The Governors are named the same).
  # intel_pstate only have powersave(default) and performance, uses specific
  # hardware registers not available to generic scaling drivers for determining
  # the cpu-load and bypasses the generic governor layer - that's why the
  # intel_pstate governors are different. The Governor schedutil is integrated
  # with the kernel CPU scheduler and is the preferred if any of the generic
  # governors are used.
  #
  # The cpu supports frequency boost. Example: the boost frequency is 3.30Ghz
  # and the base frequency 2.10Ghz
  # - If Turbo Boost is enabled and only one of the cores is working, the core
  # will work at a maximum of 3.30GHz.
  # - If Turbo Boost is enabled and all the cores are working, the core will
  # work at 2.10GHz.
  # boost is a hardware(software for arm) feature to raise the operating
  # frequency of some cores in a multicore package temporarily (and above the
  # sustainable frequency threshold for the whole package) under certain
  # conditions, for example if the whole chip is not fully utilized and below
  # its intended thermal or power budget.
  # For acpi-cpufreq boost is controlled by
  # /sys/devices/system/cpu/cpufreq/boost. For intel_pstate boost is controlled
  # by the driver and can be turned off by
  # echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
  #
  # info about frequency and power consumption
  # powertop - see power consumption
  # or print the instantaneous
  # watch -n.1 "awk '{print \$1*10^-6 \" W\"}' /sys/class/power_supply/BAT0/power_now"
  # i7z - see frequency for each core
  # tlp-stat -p - see governator, driver, min/max scaling freqs
  # cpupower frequency-info
  # til-stat -b -- see battery stats

  # revert to using the acpi-cpufreq driver
  boot.kernelParams = [ "intel_pstate=disable" ];

  # services.power-profiles-daemon needs to be disabled; it conflicts with tlp
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {

      # stop charging when battery reaches 80% - for improved battery life
      # Charge to full capacity by
      # tlp fullcharge bat0
      START_CHARGE_THRESH_BAT0=75;
      STOP_CHARGE_THRESH_BAT0=80;

      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";

      # Refer to the output of tlp-stat -p to determine the active scaling
      # driver and available governors.
      # https://linrunner.de/tlp/settings/processor.html#cpu-scaling-min-max-freq-on-ac-bat
      # base freq for i7-8650U CPU @ 1.90GHz
      CPU_SCALING_MIN_FREQ_ON_AC = 800000;
      CPU_SCALING_MAX_FREQ_ON_AC = 2100000;
      CPU_SCALING_MIN_FREQ_ON_BAT = 800000;
      CPU_SCALING_MAX_FREQ_ON_BAT = 2100000;


      # Enable audio power saving for Intel HDA, AC97 devices (timeout in secs).
      # A value of 0 disables, >=1 enables power saving (recommended: 1).
      # Default: 0 (AC), 1 (BAT)
      SOUND_POWER_SAVE_ON_AC=0;
      SOUND_POWER_SAVE_ON_BAT=1;

      # Runtime Power Management for PCI(e) bus devices: on=disable, auto=enable.
      # Default: on (AC), auto (BAT)
      RUNTIME_PM_ON_AC="on";
      RUNTIME_PM_ON_BAT="auto";

      # Battery feature drivers: 0=disable, 1=enable
      # Default: 1 (all)
      NATACPI_ENABLE=1;
      TPACPI_ENABLE=1;
      TPSMAPI_ENABLE=1;
    };
  };
}
