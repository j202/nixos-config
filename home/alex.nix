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

  programs = {
    home-manager.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting

        export EDITOR=nvim

        set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

        fzf_configure_bindings \
            --directory=\ee\ef \
            --git_log=\ee\el \
            --git_status=\ee\es \
            --processes=\ee\ep \
            --variables=\ee\ev
        bind \ee\eb _git_fzf_echo_branch

        set --global --export BAT_THEME "Catppuccin Mocha"
      '';
      plugins = [
        {
          name = "replay.fish";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "replay.fish";
            rev = "d2ecacd3fe7126e822ce8918389f3ad93b14c86c";
            sha256 = "TzQ97h9tBRUg+A7DSKeTBWLQuThicbu19DHMwkmUXdg=";
          };
        }
        {
          name = "fzf.fish";
          src = pkgs.fetchFromGitHub {
            owner = "patrickf1";
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

    starship.enable = true;

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

    zellij = {
      enable = true;
      settings = {
        theme = "catppuccin-mocha";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-qt;
  };
}
