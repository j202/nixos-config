# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Laptop-specific home config — shared base plus XFCE desktop.
{ pkgs, ... }:
let
  xfce_terminal_catppuccin_themes = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "xfce4-terminal";
    rev = "cbc9861bb9c40fad098cf55d4b53879e6f9a737c";
    sha256 = "xVK77p+kmwhxPHveHhmVglUt4bN2GUxhlhllS2wwvzs="; # cspell:ignore kmwhx Uxhlhll wwvzs
  };
in
{
  imports = [
    ./alex.nix
    ./modules/git-personal-identity.nix
    ./modules/git-github-ssh.nix
  ];

  home.file.".local/share/xfce4/terminal/colorschemes".source =
    xfce_terminal_catppuccin_themes + "/themes";
}
