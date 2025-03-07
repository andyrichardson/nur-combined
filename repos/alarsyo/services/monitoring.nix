{ config, lib, pkgs, ... }:

with lib;

let cfg = config.my.services.monitoring;
in {
  options.my.services.monitoring = {
    enable = mkEnableOption "Enable monitoring";
    useACME = mkEnableOption "Get HTTPS certs";

    domain = mkOption {
      type = types.str;
      default = "monitoring.${config.networking.domain}";
      example = "monitoring.example.com";
      description = "Domain to use in reverse proxy";
    };
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      domain = cfg.domain;
      port = 3000;
      addr = "127.0.0.1";

      provision = {
        enable = true;

        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString config.services.prometheus.port}";
          }
        ];

        dashboards = [
          {
            name = "Node Exporter";
            options.path = ./grafana-dashboards;
            disableDeletion = true;
          }
        ];
      };
    };

    services.prometheus = {
      enable = true;
      port = 9090;
      listenAddress = "127.0.0.1";

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9100;
        };
      };

      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };

    services.nginx = {
      virtualHosts.${config.services.grafana.domain} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
          proxyWebsockets = true;
        };

        forceSSL = cfg.useACME;
        enableACME = cfg.useACME;
      };
    };
  };
}
