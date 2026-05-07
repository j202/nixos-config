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
            rev = "00c0123d8e4fa54f17f930f0d3e53e521a9cbad6";
            sha256 = "C1gyeRpoOLRnMOlXeBilaLJxX8UpGqCUsgZcoS8w18I=";
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
        url."git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
    };

    zellij.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-qt;
  };
}
