# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  description = "NixOS configurations";

  nixConfig = {
    extra-substituters      = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { nixpkgs-stable, nixpkgs-unstable, home-manager, home-manager-stable, catppuccin, agenix, noctalia, ... }: {
    nixosConfigurations = {

      # Dell XPS M1330 — pinned to nixos-25.11 stable
      xpsm1330 = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/xpsm1330/configuration.nix
          agenix.nixosModules.default
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
          agenix.nixosModules.default
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alex = import ./home/alex-pc.nix;
            home-manager.sharedModules = [
              catppuccin.homeModules.catppuccin
              noctalia.homeModules.default
            ];
          }
          # Workaround for NixOS/nixpkgs#513245: pkgsi686Linux.openldap test
          # suite failures break lutris builds on x86_64.
          {
            nixpkgs.overlays = [
              (_: prev: {
                openldap = prev.openldap.overrideAttrs {
                  doCheck = !prev.stdenv.hostPlatform.isi686;
                };
              })
            ];
          }
        ];
      };

    };
  };
}
