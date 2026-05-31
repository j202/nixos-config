# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Standalone home-manager for non-NixOS Linux.
# Apply with: home-manager switch --flake ~/nixos-config#alex-standalone --impure
{ lib, ... }:
{
  imports = [ ./alex.nix ];

  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  # Identity in a local file, not in this repo
  programs.git.includes = [ { path = "~/.gitconfig.d/identity"; } ];

  # No personal GPG/SSH agent
  services.gpg-agent.enable = lib.mkForce false;

  # No auto-update — may not have push access to this repo
  systemd.user.timers.flake-update.Install.WantedBy = lib.mkForce [ ];

  # CLI tools via mise so they are visible inside containers that mount $HOME.
  # ~/.local/bin/mise (see README: Bootstrap) is what containers use;
  # the Nix-managed mise below handles the host and config.
  programs.mise = {
    enable = true;
    globalConfig.settings.tools = {
      bat = "latest";
      fd = "latest";
      fzf = "latest";
      jq = "latest";
      ripgrep = "latest";
      yazi = "latest";
    };
  };
}
