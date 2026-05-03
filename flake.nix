# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  description = "NixOS configurations";

  inputs = {
    # Laptop stays on stable — old hardware needs predictability
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    # PC tracks unstable for newest packages
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, home-manager-stable, catppuccin, ... }: {
    nixosConfigurations = {

      # Dell XPS M1330 — pinned to nixos-25.11 stable
      xpsm1330 = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/xpsm1330/configuration.nix
          home-manager-stable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alex = import ./home/alex-laptop.nix;
          }
        ];
      };

      # ASRock Z790 / i7-13700K / RX 7900 XT — tracks nixos-unstable
      alex-pc = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/alex-pc/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alex = import ./home/alex-pc.nix;
            home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
          }
        ];
      };

    };
  };
}
