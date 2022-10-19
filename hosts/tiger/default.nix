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
        doom = {
          enable = true;
          configRepoUrl = "https://github.com/pawsen/doom.d";
        };
      };
      vim.enable = true;
    };
    shell = {
      direnv.enable = true;
      git.enable    = true;
      gnupg.enable  = true;
      tmux.enable   = true;
      zsh.enable    = true;
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
    libreoffice
    jq
    htop
    freecad
    #  weechat  # cli-irc
    unstable.signal-desktop
    unstable.discord
    element-desktop
    flameshot
    jpegoptim
    zathura  # pdf-reader with vim bindings

    # development
    insomnia  # REST api client

    usbutils  # lsusb
    pciutils

    # dropin for docker-compose
    podman-compose
    distrobox
  ];

  # from nixos specific recipes
  # These can include systemd unit files, etc
  programs = {
    adb.enable = true;
    nm-applet.enable = true;

    # for locking the screen with zzz
    slock.enable = true;
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


    # augmenting direnv with lorri, which will cache nix builds and speed up
    # direnv tremendously
    lorri.enable = true;
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


  # home-manger packages
  # home-manager.users.${config.user.name}.services = {
  #   flameshot.enable = true;
  # };

  # layouts
  services.xserver = {
    layout = "us,dk";
    xkbVariant = ",nodeadkeys";
    # let CAPS-led indicate layout
    # xkbOptions = "grp:lctrl_toggle,grp_led:caps,ctrl:none";
    xkbOptions = "grp:shift_caps_toggle,grp_led:caps,caps:escape";
    displayManager = {
      autoLogin = { enable = true; user = "paw"; };
    };
  };
  # Use same config for linux console
  console.useXkbConfig = true;
  # don't suspend when closing the lid on external power
  # https://nixos.org/manual/nixos/stable/options.html#opt-services.logind.lidSwitchExternalPower
  services.logind.lidSwitchExternalPower = "ignore";

  networking.networkmanager.enable = true;
  # The global useDHCP flag is deprecated, therefore explicitly set to false
  # here. Per-interface useDHCP will be mandatory in the future, so this
  # generated config replicates the default behaviour.
  networking.useDHCP = false;

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
      defaultNetwork.dnsname.enable = true;
    };
  };

  # Personal backups
  # remember to create the backup dir: mkdir /.subvols/btrbk
  # see the following for how to setup ssh push
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/btrbk.nix
  # services.btrbk = {
  #   instances = {
  #     local = {
  #       onCalendar = "*:0/15"; # each 15 min. Before: "minutely";
  #       settings = {
  #         timestamp_format = "long";
  #         snapshot_preserve_min = "2d";
  #         snapshot_preserve = "48h 20d 6m";
  #         volume = {
  #           "/.subvols" = {
  #             snapshot_dir = "btrbk";
  #             subvolume = "@home";
  #             snapshot_create = "onchange";
  #           };
  #         };
  #       };
  #     };
  #   };
  # };

}
