{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.prismLauncher;
  prismJsonConfig = pkgs.writeText "prism-settings.json" (builtins.toJSON cfg.settings);
in
{
  options.programs.prismLauncher = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the managed user-level Prism Launcher setup.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.prismlauncher;
      description = "The Prism Launcher package to install.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = with types; attrsOf (attrsOf anything);
      };
      default = { };
      description = "INI settings to merge into prismlauncher.cfg.";
    };
  };

  config = mkIf cfg.enable {
    # Installs the package cleanly into the target user environment profile
    home.packages = [ cfg.package ];

    # Uses Home Manager activation cycle to natively map properties
    home.activation.mapPrismSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.python3}/bin/python3 -c '
      import os
      import json
      import configparser

      config_path = os.path.expanduser("~/.local/share/PrismLauncher/prismlauncher.cfg")
      os.makedirs(os.path.dirname(config_path), exist_ok=True)

      config = configparser.ConfigParser(interpolation=None)
      config.optionxform = str

      if os.path.exists(config_path):
          config.read(config_path)

      with open("${prismJsonConfig}", "r") as f:
          updates = json.load(f)

      for section, keys in updates.items():
          if not config.has_section(section):
              config.add_section(section)
          for key, value in keys.items():
              if isinstance(value, bool):
                  value = "true" if value else "false"
              config.set(section, key, str(value))

      with open(config_path, "w") as f:
          config.write(f, space_around_delimiters=False)
      '
    '';
  };
}
