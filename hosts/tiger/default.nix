{ pkgs, config, lib, ... }:
{
  imports = [
    # ../home.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  modules = {
    dev = {
      python = {
        enable = true;
      };
    };
    desktop = {
      # gnome.enable = true;
      bspwm.enable = true;
      # awesomewm.enable = true;
      apps = {
        rofi.enable = true;
        # godot.enable = true;
      };
      browsers = {
        default = "firefox";
        firefox.enable = true;
      };
      term = {
        default = "alacritty";
        st.enable = true;
        alacritty.enable = true;
      };
      media = {
        # daw.enable = true;
        documents.enable = true;
        graphics = {
          enable = true;
          sprites.enable = false;
        };
        mpv.enable = true;    # video player
        # recording.enable = true;
        # spotify.enable = true;
      };
    };
    editors = {
      default = "nvim";
      emacs = {
        enable = true;
        daemon = true;
        doom = {
          enable = true;
          configRepoUrl = "https://github.com/pawsen/doom.d";
        };
      };
      vim.enable = true;
    };
    shell = {
      git.enable    = true;
      gnupg.enable  = true;
      tmux.enable   = true;
      zsh.enable    = true;
      fish.enable   = true;
      vaultwarden = {
        enable = true;
        config.server = "vault.bitwarden.com";
      };
    };
    services = {
      ssh.enable = true;
      syncthing.enable = true;
    };
    theme.active = "alucard";
  };

  hardware = {
    # Enables rtl-sdr udev rules, ensures ‘plugdev’ group exists, and blacklists
    # DVB kernel modules. This is a prerequisite to using devices supported by
    # rtl-sdr without being root, since rtl-sdr USB descriptors will be owned by
    # plugdev through udev.
    rtl-sdr.enable = true;
  };

  ## Local config
  programs.ssh.startAgent = true;
  services.openssh.startWhenNeeded = true;

  # user specific packages -- from nixpkgs
  # To install packages with optional build flags, see
  # https://www.reddit.com/r/NixOS/comments/ft7dsg/how_to_install_package_with_optional_build_flags
  user.packages = with pkgs; [
    # unstable.alacritty
    transmission-qt
    calibre
    libreoffice
    htop
    freecad
    # python packages required to install InventorLoader addon to freecad
    # python3Packages.ezdxf
    # python3Packages.xlrd
    # xlutils is not in nixos. It's deprecated. See also https://github.com/jmplonka/InventorLoader/pull/78
    # python3Packages.xlutils
    # python3Packages.xlwt

    #  weechat  # cli-irc
    unstable.signal-desktop
    unstable.discord
    element-desktop
    flameshot  # screen-shot tool
    jpegoptim  # compress and optimize jpeg's from cli
    zathura  # pdf-reader with vim bindings
    poppler_utils  # convert pdf to png using pdftoppm input.pdf output -png
    xclip    # Patch for Clipboard Across X Programs
    arandr     # Graphical Interface for xrandr
    autorandr
    rclone  # sync tool for major cloud providers
    trash-cli  # move to trash
    hydra-check  # check build status for packages on hydra

    usbutils  # lsusb
    pciutils

    # dropin for docker-compose
    podman-compose
    distrobox

    # modern replacements for old-school stuff
    curlie # wraps curl with modern defaults and httpie-like syntax highlighting
    jq # cli for transforming JSON
    yq # yq is like jq, meaning that it's like sed for YAML data
    # development
    insomnia  # REST api client
    diffoscope # comparison of files, archives, and directories.

    tailscale
    xdragon # simple drag-and-drop source/sink for X
  ];

  # from nixos specific recipes
  # These can include systemd unit files, etc
  programs = {
    adb.enable = true;
    nm-applet.enable = true;

    # for locking the screen with zzz
    slock.enable = true;

    # Run unpatched dynamic binaries on NixOS.
    # While many proprietary packages in nixpkgs have already been patched with
    # autoPatchelfHook patching, this is not the case for e.g. downloaded binary
    # executables
    # see https://github.com/Mic92/nix-ld for more
    nix-ld.enable = true;
  };

  users.defaultUserShell = pkgs.fish;
  # home-mamanger packages
  home-manager.users.${config.user.name}.programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # enableFishIntegration = true;
    };
    # gives C-r, C-t(find file) and M-c(cd into sub-dirs) shortcuts
    fzf.enable = true;
    dircolors.enable = true;
    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
      };
    };
    lsd = {
      enable = true;
      # ls, ll, la, lt ...
      enableAliases = true;
    };
    nix-index.enable = true;

    rbw = {
      # Note to users of the official Bitwarden server (at bitwarden.com): The
      # official server has a tendency to detect command line traffic as bot
      # traffic (see this issue for details). In order to use rbw with the
      # official Bitwarden server, you will need to first run rbw register to
      # register each device using rbw with the Bitwarden server. This will
      # prompt you for your personal API key
      enable = true;
      package = (pkgs.rbw.override { withFzf = true; withRofi = true;});
      settings = {
        # if base_url is unset (null), it will default to api.bitwarden.com
        # base_url = "https://vault.bitwarden.com";
        # identity_url = "https://identity.bitwarden.com";
        # notifications_url = "https://notifications.bitwarden.com";
        # email = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.bitwarden-email.path})";
        email = "pawsen+bitwarden@gmail.com";
        # pinentry = pkgs.pinentry-curses;
        pinentry = pkgs.pinentry-gtk2;
      };
    };
  };

  # dialout group owns the device files - for uploading to arduino, etc
  # plugdev is for rtl-sdr
  user.extraGroups = [ "dialout" "networkmanager" "adbusers" "docker" "plugdev" "wireshark" ];

  # Enable autodiscovery of network printers (UDP port 5353)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # openFirewall defaults to true, but let's be explicit
    openFirewall = true;
  };
  services.printing = {
    # Enable CUPS to print documents.
    enable = true;
    drivers = with pkgs; [hplip];
    # only open the firewall if a local printer should be shared
    # openFirewall = true;
  };

  services = {
    # gnome virtual fs. For automounting and trash. For CLI tool, see udevil.
    gvfs.enable = true;

    # Thumbnail previews for file-managers
    tumbler.enable = true; # Thumbnail support for images

    # bluetooth gui
    blueman.enable = true;

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    # A fuse filesystem that dynamically populates contents of /bin and
    # /usr/bin/ so that it contains all executables from the PATH of the
    # requesting process. This allows executing FHS based programs on a non-FHS
    # system. For example, this is useful to execute shebangs on NixOS that
    # assume hard coded locations like /bin or /usr/bin etc.
    # see https://github.com/Mic92/envfs for details
    # XXX: disables as it seems to crash the system...
    # envfs.enable = true;
  };

  #environment.shellAliases = {
  #  # pass = "gopass";
  #};

  # system packages
  environment.systemPackages = with pkgs; [
    chromium
    file

    # file manager incl plugins
    (xfce.thunar.override { thunarPlugins = [ xfce.thunar-archive-plugin xfce.thunar-volman ]; })
    xarchiver  # for extracting using right-click
    # gnome.file-roller  # requires a lot of dependencies

    # thumblers
    # https://wiki.archlinux.org/title/File_manager_functionality#Thumbnail_previews
    libgsf   # odf
    poppler  # pdf

    # machine emulator and virtualization
    qemu
    quickemu

    # rtl-sdr-osmocom is better for rtl-sdr v4
    # XXX as of 2025, rtl-sdr point to rtl-sdr-osmocom
    # (urh.override { rtl-sdr = rtl-sdr-osmocom; })
    # my.urh
    # (rtl_433.override { rtl-sdr = rtl-sdr-osmocom; })

    # NetworkManager can generate WPA2 Enterprise profiles with graphical front ends. nmcli and nmtui
    # do not support this, but may use existing profiles.
    # It might be possible to create a profile using nmcli, https://unix.stackexchange.com/a/334675
    # but an easier solution is to use nm-applet.
    # Run nm-applet without a systray and kill it after use (no extra memory is used then)
    (writeShellScriptBin "nmgui" ''
      ${pkgs.networkmanagerapplet}/bin/nm-applet 2>&1 > /dev/null &
      NM_PID=$!
      # Ensure nm-applet is killed on exit or interruption
      trap "kill $NM_PID 2>/dev/null" EXIT INT TERM
      ${pkgs.stalonetray}/bin/stalonetray 2>&1 > /dev/null
      # # Fallback kill (in case trap missed) - but will that ever happen?
      ${pkgs.procps}/bin/pkill nm-applet
    '')
    networkmanagerapplet
    stalonetray
    procps  # for pkill
  ];

  # NixOS sets /tmp to be backed by disk by default. But we change it to ram in modules/security.nix
  # https://search.nixos.org/options?query=useTmp
  # building packages runs inside of /tmp (which is now constrained by ram size)
  # use /var/tmp instead which is backed by disk:
  # (OR use the build-dir option to the nix command)
  # (https://nix.dev/manual/nix/2.24/command-ref/conf-file.html#conf-build-dir)
  # XXX use the build-dir option. Kept as note for the future.
  # systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

  # XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype
  # get search path in decreasing order
  # XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default application/pdf
  # .desktop files are located at
  # ls /run/current-system/sw/share/applications
  # ls /etc/profiles/per-user/paw/share/applications/

  # When packages are included in environment.systemPackages, a nixos module for
  # creating the system will look for <pkg>/share/applications/*.desktop paths,
  # and add them to /run/current/sw/...
  # Generally if you want to put stuff in XDG_DATA_DIRS,you should just copy the
  # dirextories in $out/share. In this case .desktop files should be copied to
  # $out/share/applications. Remember to mkdir -p $out/share/applications
  # beforehand
  # https://discourse.nixos.org/t/where-are-desktop-files-located/17391
  xdg.mime.defaultApplications =
    {
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "image/png" = [
        "feh.desktop"
        "gimp.desktop"
      ];
    };


  # layouts
  services.xserver = {
    layout = "us,dk";
    xkbVariant = ",nodeadkeys";
    # let CAPS-led indicate layout
    # xkbOptions = "grp:lctrl_toggle,grp_led:caps,ctrl:none";
    xkbOptions = "grp:shift_caps_toggle,grp_led:caps,caps:escape";
    # displaylink is for usb-c dock
    # the driver must be downloaded manually and put in /nix/store. See
    # https://nixos.wiki/wiki/Displaylink
    videoDrivers = [ "displayLink" "modesetting" ];
    displayManager = {
      autoLogin = { enable = true; user = "paw"; };
    };
  };
  # Use same config for linux console
  console.useXkbConfig = true;
  # don't suspend when closing the lid on external power
  # https://nixos.org/manual/nixos/stable/options.html#opt-services.logind.lidSwitchExternalPower
  services.logind.lidSwitchExternalPower = "ignore";

  networking = {
    # For DOH
    nameservers = [ "127.0.0.1" "::1" ];
    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";

    networkmanager.enable = true;
    # If using NetworkManager:
    networkmanager.dns = "none";
  };
  # This should force NetworkManager to use a specific DNS server, instead of
  # the ones provided by DHCP. Does not seems to work. Use bin/update-dns script
  # instead
  # networking.networkmanager.insertNameservers = [ "1.1.1.1" "1.0.0.1"];

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      # Specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      # The proxy will automatically pick working servers from this list,
      # ranging them after latency, if server_names is commented(default).
      server_names = [ "scaleway-fr" "cloudflare" "google" "yandex" ];
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };
  # hibernate after fixed time on sleep to prevent draining the battery
  # ensure that hibernation is not disabled by a kernel parameter (nohibernate):
  # cat /proc/cmdline         # must not have nohibernate
  # cat /sys/power/state      # needs disk for hibarnation
  # Two types of sleep, s2idle is modern, OS controlled and fast. Uses 1-2W
  # cat /sys/power/mem_sleep
  # Check the sleep time before waking up
  # systemd-analyze cat-config systemd/sleep.conf
  # cat /sys/power/mem_sleep  # [s2idle] deep   (brackets mark the current default)
  # systemctl suspend-then-hibernate
  # journalctl -b -u systemd-suspend-then-hibernate.service
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=3h
    SuspendState=mem
  '';
  # Dedicated Chrome instance to log into captive portals without messing with DNS settings
  # With captive portals we need to use the DNS provided by DHCP. This program
  # sets up a small proxy using the DHCP dns (from nmcli dev show | grep IP4.DNS
  # if using networkmanager). The browser then uses the proxy to connect to the
  # captive portal. The proxy stops when the browser exists.
  # see https://words.filippo.io/captive-browser/
  #
  # This module(captive-browser) uses the proxy pkgs.captive-browser, defined:
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/captive-browser/default.nix
  programs.captive-browser = {
    enable = true;
    interface = "wlp2s0";

    # it should be possible to use firefox instead, as described here:
    # https://github.com/FiloSottile/captive-browser/issues/20#issuecomment-757305465
    # This requires setting up a dedicated firefox profile in home-manager and
    # changing the browser setting for this module to
    # browser = firefox -P "captive-browser" --no-remote --private-window "http://detectportal.firefox.com/success.txt";
  };


  time.timeZone = "Europe/Copenhagen";
  # For redshift, mainly
  location = (if config.time.timeZone == "America/Toronto" then {
    latitude = 43.70011;
    longitude = -79.4163;
  } else if config.time.timeZone == "Europe/Copenhagen" then {
    latitude = 55.88;
    longitude = 12.5;
  } else {});

  virtualisation = {
    # podman is a dropin replacement for docker
    # https://nixos.wiki/wiki/Podman
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # https://www.reddit.com/user/FictionWorm____/comments/vho8el/borgbackup_setup_ssh_for_a_remote_repo/
  # services.borgbackup.jobs.tiger = {
  #   paths = "/home/paw";
  #   encryption.mode = "none";
  #   environment.BORG_RSH = "${pkgs.tailscale}/bin/tailscale ssh";
  #   repo = "btrbk@hetzner:/mnt/share/backups/tiger";
  #   compression = "auto,zstd";
  #   startAt = "daily";
  # };

  # restic can only do encrypted backups. It's a feature!
  # services.restic.backups = {
  #   tiger = {
  #     # user = "btrbk";
  #     # https://forum.restic.net/t/slow-backup-with-many-small-files-via-sftp/7277
  #     repository = "sftp::/mnt/share/backups/tiger";
  #     extraOptions = [
  #       "sftp.command='tailscale ssh root@hetzner -s sftp'"
  #       # "sftp.command='ssh btrbk@ssh.pawsen.net -i /home/user/.ssh/btrbk -s sftp'"
  #     ];
  #     initialize = true; # initializes the repo, don't set if you want manual control
  #     # read thhis, for passwordfile and agenix
  #     # https://www.arthurkoziel.com/restic-backups-b2-nixos/
  #     passwordFile = "<path>";
  #     paths = [ "/home/paw" ];
  #   };
  # };

  # Personal backups
  # ensure backup dir /.subvols/snapshots exists
  # mode: 1700, sticky bit, read/write/execute by owner
  systemd.tmpfiles.rules = [
    "d /.subvols/snapshots 1700 root root"
  ];
  # see the following for how to setup ssh push
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/btrbk.nix
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/backup/btrbk.nix
  services.btrbk.instances."btrbk" = {
    # systemd.time, https://manpages.ubuntu.com/manpages/xenial/man7/systemd.time.7.html#calendar%20events
    # Persistent = true; (run timer on boot if calendar event is passed, eg. by
    # computer being turned off) is set by btrbk.nix
    onCalendar = "daily";
    settings = {


      # only relevant for streaming snapshots - requires host to have btrfs drives
      # ssh_user = "btrbk";
      # ssh_identity = "/home/paw/.ssh/btrbk";
      # stream_compress = "lz4";
      snapshot_preserve_min = "2d";
      snapshot_preserve = "48h 20d 6m";
      volume = {
        "/.subvols" = {
          subvolume = "@home";
          snapshot_dir = "snapshots";
          # requires btrfs drive at the recieving end
          # target = "ssh://ssh.pawsen.net/mnt/share/backups/tiger";
        };
      };
    };
  };

}
