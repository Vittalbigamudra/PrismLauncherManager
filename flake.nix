{
  description = "A universal, declarative Prism Launcher module suite for NixOS and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    # Clean public access layers exposed for consumers
    nixosModules.prismLauncher = ./modules/nixos.nix;
    homeManagerModules.prismLauncher = ./modules/home-manager.nix;

    # Default fallbacks to prevent errors if outputs are queried directly
    nixosModules.default = self.nixosModules.prismLauncher;
    homeManagerModules.default = self.homeManagerModules.prismLauncher;
  };
}
