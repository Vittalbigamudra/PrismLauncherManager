{
  description = "A universal, declarative Prism Launcher module suite for NixOS and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    # home manager
    nixosModules.prismLauncher = ./nixos.nix;
    homeManagerModules.prismLauncher = ./home-manager.nix;

    # nixos
    nixosModules.default = self.nixosModules.prismLauncher;
    homeManagerModules.default = self.homeManagerModules.prismLauncher;
  };
}
