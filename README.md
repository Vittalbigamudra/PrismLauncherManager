# PrismLauncherManager

Nothing much to say here.\
It manages your prism launcher.\
Check out your ~/.local/share/PrismLauncher/prismlauncher.cfg to see what options you can modify.\
Let me know if you have any questions. I'm on Discord @vaylinaut.\
If something breaks, then let me know. I will do my best to fix it.

```nix

{
  description = "Example User's System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pulling your repository down cleanly via url
    prism-manager = {
      url = "github:vaylinaut/PrismLauncherManager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, prism-manager, ... }: {
    nixosConfigurations.demo-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        # EITHER option A: They load it directly inside NixOS system modules
        prism-manager.nixosModules.prismLauncher

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vittalb = {
            imports = [
              # OR option B: They choose to import it into their Home Manager profile instead!
              prism-manager.homeManagerModules.prismLauncher
            ];

            # Installs and fully configs things on execution
            programs.prismLauncher = {
              enable = true;
              settings.General.ApplicationTheme = "dark";
            };
          };
        }
      ];
    };
  };
}

```
