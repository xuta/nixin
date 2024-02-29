{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=23.11";
  };

  outputs = { self, nixpkgs, ... }@input: {
    
    nixosConfigurations.nixin = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };

  };
}
