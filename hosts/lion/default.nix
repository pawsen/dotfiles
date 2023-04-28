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
      gnupg.enable  = false;
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
      docker.enable = true;
    };
    theme.active = "alucard";
    # vm = {
    #   vagrant.enable = false;
    # };
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
    htop
    freecad
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


    # modern replacements for old-school stuff
    curlie # wraps curl with modern defaults and httpie-like syntax highlighting
    jq # cli for transforming JSON
    yq # yq is like jq, meaning that it's like sed for YAML data
    # development
    insomnia  # REST api client

    tdesktop

    rage   # ssh-key encryption. Implicit installed by agenix.
    pinentry-gtk2   # benefit of gui pinentry: possible to view the entered password
  ];

  # from nixos specific recipes
  # These can include systemd unit files, etc
  programs = {
    adb.enable = true;
    nm-applet.enable = true;

    # for locking the screen with zzz
    slock.enable = true;

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
  };

  # dialout group owns the device files - for uploading to arduino, etc
  user.extraGroups = ["dialout" "networkmanager" "adbusers"];

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;
    printing.drivers = with pkgs; [hplip];

    # gnome virtual fs. For automounting and trash. For CLI tool, see udevil.
    gvfs.enable = true;

    # Thumbnail previews for file-managers
    tumbler.enable = true; # Thumbnail support for images
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
