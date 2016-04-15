{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.factorio;
  name = "Factorio";
  stateDir = "/var/lib/factorio";
  configFile = pkgs.writeText "factorio.conf" ''
    use-system-read-write-data-directories=true
    [path]
    read-data=${pkgs.factorio-headless}/share/factorio/data
    write-data=${stateDir}
  '';
in
{
  options = {
    services.factorio = {
      enable = mkEnableOption name;
      port = mkOption {
        type = types.int;
        default = 34197;
        description = ''
          The port to which the service should bind.

          This option will also open up the UDP port in the firewall configuration.
        '';
      };
      saveName = mkOption {
        type = types.string;
        default = "default";
        description = ''
          The name of the savegame that will be used by the server.

          When not present in ${stateDir}/saves, it will be generated before starting the service.
        '';
      };
      # TODO Add more individual settings as nixos-options?
      # TODO XXX The server tries to copy a newly created config file over the old one
      #   on shutdown, but fails, because it's in the nix store. When is this needed?
      #   Can an admin set options in-game and expect to have them persisted?
      configFile = mkOption {
        type = types.path;
        default = configFile;
        defaultText = "configFile";
        description = ''
          The server's configuration file.

          The default file generated by this module contains lines essential to
          the server's operation. Use its contents as a basis for any
          customizations.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.factorio = {
        uid             = config.ids.uids.factorio;
        description     = "Factorio server user";
        group           = "factorio";
        home            = stateDir;
        createHome      = true;
      };

      groups.factorio = {
        gid = config.ids.gids.factorio;
      };
    };

    systemd.services.factorio = {
      description   = "Factorio headless server";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

      preStart = ''
          test -e ${stateDir}/saves/${cfg.saveName}.zip || ${pkgs.factorio-headless}/bin/factorio \
            --config=${cfg.configFile} \
            --create=${cfg.saveName}
      '';

      serviceConfig = {
        User = "factorio";
        Group = "factorio";
        Restart = "always";
        KillSignal = "SIGINT";
        WorkingDirectory = stateDir;
        PrivateTmp = true;
        UMask = "0007";
        ExecStart = toString [
          "${pkgs.factorio-headless}/bin/factorio"
          "--config=${cfg.configFile}"
          "--port=${toString cfg.port}"
          "--start-server=${cfg.saveName}"
        ];
      };
    };

    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}
