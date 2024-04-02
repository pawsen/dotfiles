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
    };
    theme.active = "alucard";
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
  user.extraGroups = [ "dialout" "networkmanager" "adbusers" "docker" ];

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;
    printing.drivers = with pkgs; [hplip];

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

  ];

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
      snapshot_preserve_min = "2d";
      snapshot_preserve = "48h 20d 6m";
      volume = {
        "/.subvols" = {
          subvolume = "@home";
          snapshot_dir = "snapshots";
        };
      };
    };
  };

}
