# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  description = "NixOS configurations";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
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

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs =
    {
      nixpkgs-stable,
      nixpkgs-unstable,
      home-manager,
      home-manager-stable,
      catppuccin,
      agenix,
      noctalia,
      git-hooks,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs-unstable.legacyPackages.${system};
      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt.enable = true;
          end-of-file-fixer.enable = true;
          check-json = {
            enable = true;
            excludes = [ "^vscode/" ];
          };
          mixed-line-ending = {
            enable = true;
            name = "mixed-line-ending";
            entry = toString (
              pkgs.writeShellScript "mixed-line-ending" ''
                found=0
                for f in "$@"; do
                  if grep -qF $'\r' "''${f}"; then
                    echo "mixed-line-ending: carriage return (CR) character found in ''${f}"
                    found=1
                  fi
                done
                exit ''${found}
              ''
            );
            types = [ "text" ];
          };
          check-merge-conflict = {
            enable = true;
            name = "check-merge-conflict";
            entry = toString (
              pkgs.writeShellScript "check-merge-conflict" ''
                found=0
                for f in "$@"; do
                  if grep -qE '^(<{7}|={7}|>{7})( |$)' "''${f}"; then
                    echo "check-merge-conflict: conflict marker found in ''${f}"
                    found=1
                  fi
                done
                exit ''${found}
              ''
            );
            types = [ "text" ];
          };
          detect-private-key =
            let
              patterns = pkgs.writeText "private-key-patterns" (
                builtins.readFile ./hooks/private-key-patterns.txt
              );
            in
            {
              enable = true;
              name = "detect-private-key";
              entry = toString (
                pkgs.writeShellScript "detect-private-key" ''
                  found=0
                  for f in "$@"; do
                    if grep -qFf ${patterns} "''${f}"; then
                      echo "detect-private-key: private key material found in ''${f}"
                      found=1
                    fi
                  done
                  exit ''${found}
                ''
              );
              types = [ "text" ];
              excludes = [ "hooks/private-key-patterns\\.txt" ];
            };
          check-added-large-files = {
            enable = true;
            name = "check-added-large-files";
            entry = toString (
              pkgs.writeShellScript "check-added-large-files" ''
                max_kb=500
                found=0
                for f in "$@"; do
                  size_kb=$(du -k "''${f}" | cut -f1)
                  if [ "''${size_kb}" -gt "''${max_kb}" ]; then
                    echo "check-added-large-files: ''${f} is ''${size_kb}KB (limit: ''${max_kb}KB)"
                    found=1
                  fi
                done
                exit ''${found}
              ''
            );
          };
          shellcheck = {
            enable = true;
            types = [ "file" ];
            files = "\\.sh$";
          };
          shfmt = {
            enable = true;
            types = [ "file" ];
            files = "\\.sh$";
            entry = "${pkgs.shfmt}/bin/shfmt -w -i 2 -sr";
          };
          stylua = {
            enable = true;
          };
          markdownlint = {
            enable = true;
          };
          trim-trailing-whitespace = {
            enable = true;
            excludes = [ "\\.md$" ];
          };
          statix = {
            enable = true;
            settings.ignore = [ "hardware-configuration.nix" ];
          };
          deadnix = {
            enable = true;
            excludes = [ "hardware-configuration\\.nix" ];
          };
          cspell = {
            enable = true;
            name = "cspell";
            entry = "${pkgs.cspell}/bin/cspell lint --no-progress --no-must-find-files";
            types = [ "text" ];
            pass_filenames = true;
          };
          verify-hyprland-config = {
            enable = true;
            name = "verify-hyprland-config";
            entry = toString (
              pkgs.writeShellScript "verify-hyprland-config" ''
                root=$(git rev-parse --show-toplevel)
                attr="(builtins.getFlake \"path:$root\").nixosConfigurations.alex-pc.config.home-manager.users.alex.xdg.configFile.\"hypr/hyprland.conf\".source"
                config=$(nix build --no-link --print-out-paths --impure --expr "$attr" 2>/dev/null) \
                  || config=$(nix eval --impure --raw --expr "$attr" 2>&1) \
                  || { echo "hyprland config: nix eval failed:"; echo "$config"; exit 1; }
                [ -f "$config" ] \
                  || { echo "hyprland config: $config not in store; run nixos-rebuild switch"; exit 1; }
                exec ${pkgs.hyprland}/bin/hyprland --verify-config -c "$config"
              ''
            );
            files = "home/(modules/hyprland|alex-pc\\.nix)";
            pass_filenames = false;
          };
        };
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inherit (pre-commit-check) shellHook;
      };

      checks.${system}.pre-commit-check = pre-commit-check;

      nixosConfigurations = {

        # Dell XPS M1330 — pinned to nixos-25.11 stable
        xpsm1330 = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/xpsm1330/configuration.nix
            agenix.nixosModules.default
            home-manager-stable.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.alex = import ./home/alex-laptop.nix;
              };
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
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.alex = import ./home/alex-pc.nix;
                sharedModules = [
                  catppuccin.homeModules.catppuccin
                  noctalia.homeModules.default
                ];
              };
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

      homeConfigurations."alex-standalone" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs-unstable.legacyPackages.${system};
        modules = [ ./home/alex-standalone.nix ];
      };

    };
}
