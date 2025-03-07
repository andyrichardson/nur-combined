{ pkgs, config, lib, ... }: with lib; let
  cfg = config.programs.filebin;
in {
  options.programs.filebin = {
    enable = mkEnableOption "filebin path monitor";

    config = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };

    extraConfigFiles = mkOption {
      type = types.listOf types.path;
      default = [ ];
    };
  };

  config = {
    home.packages = mkIf cfg.enable [ pkgs.arc'private.filebin ];
    programs.filebin.extraConfig = mkMerge (map (path: ''
      source ${path}
    '') cfg.extraConfigFiles);
    xdg.configFile."filebin/config".text = ''
      ${concatStringsSep "\n" (mapAttrsToList (k: v: "${k}=${v}") cfg.config)}
      ${cfg.extraConfig}
    '';
  };
}
