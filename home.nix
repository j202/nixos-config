# vim: set ft=nix ts=2 sw=2 expandtab:_github_j202

{ config, pkgs, ... }:

let
  lazy_catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "nvim";
    rev = "v1.11.0";
    sha256 = "+tkfdGTsjb8FOhyz9IPnXrS/LkcsLY/TqJuE+Pcostw=";
  };
  xfce_terminal_catppuccin_themes = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "xfce4-terminal";
    rev = "cbc9861bb9c40fad098cf55d4b53879e6f9a737c";
    sha256 = "xVK77p+kmwhxPHveHhmVglUt4bN2GUxhlhllS2wwvzs=";
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    lazy_catppuccin
    starship
    helix
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      export EDITOR=nvim
      set fish_greeting # Disable greeting
      set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
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
          rev = "45dcb37918047816ad569d457b8fdc5956769fb4";
          sha256 = "QLK8MDYzxV/U0nlATsXb3sZ+bOYjGk3Ropa84VBFndA=";
        };
      }
    ];
  };
  programs.starship.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "j202";
        email = "j202@users.noreply.github.com";
        signingKey = "6E56467981DB0B21";
      };
      commit = {
        gpgsign = true;
      };
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      gpg = {
        program = "${pkgs.gnupg}/bin/gpg";
      };
      pull.rebase = true;
      rebase.autoSquash = true;
      init.defaultBranch = "main";
    };
  };

  home.file.".config/nvim/lua/user/plugins.lua".text = ''
    return {
      {"catppuccin/nvim", name = "catppuccin", lazy =  false },
    }
  '';
  home.file.".config/nvim/lua/plugins/colorscheme.lua".text = ''
    return {
      {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
          flavour = "mocha", -- latte, frappe, macchiato, mocha
          integrations = {
            treesitter = true,
            telescope = true,
            notify = true,
            indent_blankline = { enabled = true };
            native_lsp = {
              enabled = true,
            },
          },
        },
      },
      {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = "catppuccin",
        }
      },
    }
  '';
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    withNodeJs = true;
    withPython3 = true;

    extraPackages = with pkgs; [
      git
    ];
    extraPython3Packages = ps: with ps; [
      pip
    ];
  };

  xdg.configFile."nvim/init.lua".text = ''
    --Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    print("Lazy path:", lazypath)
    if not vim.loop.fs_stat(lazypath) then
      print("Cloning lazy.nvim...")
      local result = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
      })
      print(result)
    end
    vim.opt.rtp:prepend(lazypath)

    -- Load LazyVim
    require("lazy").setup({
      { "LazyVim/LazyVim", import = "lazyvim.plugins" },
      -- Plugins
      { import = "plugins" },
    }, {
      defaults = {
        lazy = false,
        version = false,
      }
  })
  require("user.plugins")
  '';
  xdg.configFile."nvim/lua/plugins/.keep".text = "";
  xdg.configFile."nvim/lua/config/options.lua".text = ''
    vim.notify = function(msg, level)
      if level == vim.log.levels.ERROR then
        vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true,  {})
        vim.fn.getchar()
      end
    end
    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undofile = false
    vim.g.colorscheme = "catppuccin"
  '';

  home.file.".local/share/xfce4/terminal/colorschemes".source = xfce_terminal_catppuccin_themes + "/themes";

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/alex/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
