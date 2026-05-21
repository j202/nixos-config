# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Shared home-manager config for alex on all machines.
# pkgs comes from the machine's nixpkgs (stable on xpsm1330, unstable on alex-pc).

{ config, pkgs, ... }:
{
  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    stateVersion = "25.11";

    packages = with pkgs; [
      starship
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/alex/nixos-config/lazyvim";

  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/alex/nixos-config/vscode/settings.json";
  xdg.configFile."Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/alex/nixos-config/vscode/keybindings.json";

  programs = {
    home-manager.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting

        export EDITOR=nvim

        set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
      '';
      functions = {
        nix-diff = ''
          set --local profile /nix/var/nix/profiles/system
          set --local gen1
          set --local gen2
          if contains -- --help $argv; or contains -- -h $argv
            echo "Usage: nix-diff [gen1 gen2]"
            echo ""
            echo "Diff package changes between two NixOS generations."
            echo ""
            echo "  nix-diff          Diff the last two generations"
            echo "  nix-diff G1 G2    Diff specific generation numbers"
            echo ""
            echo "To list available generations:"
            echo "  nix-env --list-generations --profile $profile"
            echo ""
            echo "Profile: $profile"
            echo "  Each generation is a symlink at $profile-N-link"
            echo "  The current system is /run/current-system"
            echo "  All profiles live under /nix/var/nix/profiles/"
            return 0
          else if test (count $argv) -eq 2
            set gen1 $argv[1]
            set gen2 $argv[2]
          else if test (count $argv) -eq 0
            set --local gens (nix-env --list-generations --profile $profile | awk '{print $1}' | tail --lines=2)
            if test (count $gens) -lt 2
              echo "nix-diff: need at least 2 generations" >&2
              return 1
            end
            set gen1 $gens[1]
            set gen2 $gens[2]
          else
            echo "Usage: nix-diff [gen1 gen2]" >&2
            echo "Try 'nix-diff --help' for more information." >&2
            return 1
          end
          nix store diff-closures $profile-$gen1-link $profile-$gen2-link
        '';
        # Rewrites HTTPS→SSH for interactive shell use only; Neovim/lazy.nvim bypass fish functions and use HTTPS directly (no passphrase prompts).
        git = ''
          command git -c 'url.git@github.com:.insteadOf=https://github.com/' $argv
        '';
        fish_user_key_bindings = ''
          bind --erase --preset alt-e
          bind -M insert --erase --preset alt-e
          bind alt-e,alt-e edit_command_buffer
          bind -M insert alt-e,alt-e edit_command_buffer
          fzf_configure_bindings \
              --directory=alt-e,alt-f \
              --git_log=alt-e,alt-l \
              --git_status=alt-e,alt-s \
              --processes=alt-e,alt-p \
              --variables=alt-e,alt-v
          bind alt-e,alt-b _git_fzf_echo_branch
          bind -M insert alt-e,alt-b _git_fzf_echo_branch
        '';
      };
      plugins = [
        {
          name = "replay.fish";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran"; # cspell:ignore jorgebucaran
            repo = "replay.fish";
            rev = "d2ecacd3fe7126e822ce8918389f3ad93b14c86c";
            sha256 = "TzQ97h9tBRUg+A7DSKeTBWLQuThicbu19DHMwkmUXdg=";
          };
        }
        {
          name = "fzf.fish";
          src = pkgs.fetchFromGitHub {
            owner = "patrickf1"; # cspell:ignore patrickf
            repo = "fzf.fish";
            rev = "8920367cf85eee5218cc25a11e209d46e2591e7a";
            sha256 = "T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
          };
        }
        {
          name = "git-fzf.fish";
          src = pkgs.fetchFromGitHub {
            owner = "j202";
            repo = "git-fzf.fish";
            rev = "65aef2bc337671c6afde8c3d674a7eae73bd6602";
            sha256 = "zHRhRcACFjGjTHRYik/I74OLcULctam2M9+DWlZmIMc=";
          };
        }
      ];
    };

    starship = {
      enable = true;
      settings = {
        os.disabled = false;

        shell = {
          disabled = false;
          fish_indicator = "󰈺";
          bash_indicator = "";
          zsh_indicator = "󰬡";
          unknown_indicator = "󰋗";
        };
      };
    };

    bash.enable = true;

    bat.enable = true;

    btop.enable = true;

    fzf = {
      enable = true;
      defaultOptions = [
        "--cycle"
        "--layout=reverse"
        "--border"
        "--height=90%"
        "--preview-window=wrap"
        "--marker=*"
      ];
    };

    tmux.enable = true;

    yazi = {
      enable = true;
      shellWrapperName = "y";
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "j202";
          email = "j202@users.noreply.github.com";
          signingKey = "6E56467981DB0B21";
        };
        commit.gpgsign = true;
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
        diff = {
          guitool = "meld";
          meld = "nvimdiff";
        };
        difftool.guiDefault = true;
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        fetch.prune = true;
        pull.rebase = true;
        rebase.autoSquash = true;
        init.defaultBranch = "main";
      };
    };

    zellij.enable = true;
  };

  systemd.user.services.flake-update = {
    Unit.Description = "Update nix flake inputs";
    Service = {
      Type = "oneshot";
      ExecStart = toString (
        pkgs.writeShellScript "flake-update" ''
          ${pkgs.nix}/bin/nix flake update --flake /home/alex/nixos-config && \
          ${pkgs.libnotify}/bin/notify-send \
            --app-name "NixOS" \
            "Flake inputs updated" \
            "Review changes and rebuild with nixos-rebuild switch"
        ''
      );
    };
  };

  systemd.user.timers.flake-update = {
    Unit.Description = "Weekly nix flake update";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-qt;
  };
}
