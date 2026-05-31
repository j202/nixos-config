# vim: set ft=nix ts=2 sw=2 sts=2 et:
{ pkgs, ... }:
{
  programs.git.settings = {
    user = {
      name = "j202";
      email = "j202@users.noreply.github.com";
      signingKey = "6E56467981DB0B21";
    };
    commit.gpgsign = true;
    gpg.program = "${pkgs.gnupg}/bin/gpg";
  };
}
