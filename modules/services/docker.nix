{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.docker;
    configDir = config.dotfiles.configDir;
in {
  options.modules.services.docker = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # docker
      # docker-compose

      # dropin for docker-compose
      podman-compose
      distrobox
    ];

    env.DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
    env.MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker/machine";
    user.extraGroups = [ "docker" ];
    modules.shell.zsh.rcFiles = [ "${configDir}/docker/aliases.zsh" ];

    virtualisation = {
      # docker = {
      #   enable = true;
      #   autoPrune.enable = true;
      #   enableOnBoot = mkDefault false;
      #   # HOWTO: enable ipv6 in docker. But don't do it!
      #   # https://medium.com/@skleeschulte/how-to-enable-ipv6-for-docker-containers-on-ubuntu-18-04-c68394a219a2
      #   # extraOptions = "--ipv6 --fixed-cidr-v6 2001:db8:1::/64";
      #   # Then enable IPv6 in the docker-compose.yaml file by adding a networks section
      #   # Check that IPv6 is enabled with dk network inspect docker0 (the base)
      #   # and the container specific network
      #   # To enable IPv6 internet access from containers, enable NAT for the private Docker subnet on the host:
      #   # : ip6tables -t nat -A POSTROUTING -s 2001:db8:1::/64 ! -o docker0 -j MASQUERADE
      #   # (and find a way to make it persistent)
      #   # listenOptions = [];
      # };

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
  };
}
