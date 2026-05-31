# vim: set ft=nix ts=2 sw=2 sts=2 et:
_: {
  # Rewrites HTTPS→SSH for interactive shell use only; Neovim/lazy.nvim bypass fish functions and use HTTPS directly (no passphrase prompts).
  programs.fish.functions.git = ''
    command git -c 'url.git@github.com:.insteadOf=https://github.com/' $argv
  '';
}
