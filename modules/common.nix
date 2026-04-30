# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Shared NixOS configuration — imported by all machines.
{ config, lib, pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Keyboard layout shared across X11 and Wayland (via xkb)
  services.xserver.xkb = {
    layout = "gb";
    options = "ctrl:nocaps";
  };

  services.libinput.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.fstrim.enable = true;  # no-op on HDDs, beneficial on SSDs
  services.openssh.enable = true;

  users.users.alex = {
    isNormalUser = true;
    extraGroups = lib.mkDefault [ "wheel" "networkmanager" ];
    packages = with pkgs; [ tree ];
    shell = pkgs.fish;
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.enableRedistributableFirmware = true;
  security.sudo.enable = true;

  environment.systemPackages = with pkgs; [
    bat
    brightnessctl
    btop
    cargo
    clippy
    curl
    eza
    fd
    ffmpeg
    file
    fish
    fzf
    gcc
    gh
    git
    gnumake
    go
    golint
    gopls
    gotools
    htop
    jq
    lazygit
    lua-language-server
    luarocks
    meld
    mpv
    neovim
    nil
    nodejs
    pavucontrol
    pciutils
    pkg-config
    playerctl
    pyright
    python3
    python3Packages.numpy
    python3Packages.pip
    python3Packages.requests
    python3Packages.virtualenv
    ripgrep
    rsync
    rust-analyzer
    rustc
    rustfmt
    statix
    tmux
    tree-sitter
    unzip
    usbutils
    vim
    wget
    yazi
    zellij
    zip
  ];

  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.roboto-mono
      nerd-fonts.symbols-only
      noto-fonts-emoji
    ];
  };

  environment.shells = [ pkgs.fish ];
  programs.fish.shellAliases = {
    ll = "eza --long --header --group-directories-first --icons=auto --group";
    la = "eza --long --header --group-directories-first --icons=auto --group --all --all";
  };
}
