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
      description = "Enable the managed system-wide Prism Launcher setup.";
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
    # Installs the package globally for the entire OS
    environment.systemPackages = [ cfg.package ];

    # NixOS system activation hook to safely patch user configs
    system.activationScripts.mapPrismSettings = stringAfter [ "users" ] ''
      ${pkgs.python3}/bin/python3 -c '
      import os
      import json
      import configparser
      import glob

      # Find regular user home directories on NixOS dynamically
      user_homes = [os.path.expanduser(f"~{u}") for u in os.listdir("/home") if os.path.isdir(os.path.join("/home", u))]
      # Include root just in case
      user_homes.append("/root")

      with open("${prismJsonConfig}", "r") as f:
          updates = json.load(f)

      for home in user_homes:
          config_path = os.path.join(home, ".local/share/PrismLauncher/prismlauncher.cfg")
          
          # Only apply configurations if the path or the dotfiles directory structure exists
          if os.path.exists(os.path.dirname(config_path)):
              config = configparser.ConfigParser(interpolation=None)
              config.optionxform = str

              if os.path.exists(config_path):
                  config.read(config_path)

              for section, keys in updates.items():
                  if not config.has_section(section):
                      config.add_section(section)
                  for key, value in keys.items():
                      if isinstance(value, bool):
                          value = "true" if value else "false"
                      config.set(section, key, str(value))

              with open(config_path, "w") as f:
                  config.write(f, space_around_delimiters=False)
              
              # Ensure correct ownership since system scripts execute as root
              stat = os.stat(os.path.dirname(config_path))
              os.chown(config_path, stat.st_uid, stat.st_gid)
      '
    '';
  };
}
