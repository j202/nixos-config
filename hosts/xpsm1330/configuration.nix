# vim: set ft=nix ts=2 sw=2 sts=2 et:
{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;

  # Limit RAM to 2 GB — hardware cap on this machine
  boot.kernelParams = [ "mem=2G" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "xpsm1330";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nouveau" ];
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
    xkb = {
      layout = "gb";
      options = "ctrl:nocaps";
    };
  };

  services.pulseaudio.enable = true;
  services.pipewire.enable = false;
  services.pipewire.pulse.enable = false;

  services.libinput.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
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

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 1;
  };

  environment.systemPackages = with pkgs; [
    bat
    btop
    cargo
    clippy
    curl
    eza
    fd
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
    lazygit
    lua-language-server
    luarocks
    meld
    neovim
    nil
    nodejs
    pciutils
    pkg-config
    pyright
    python3
    python3Packages.numpy
    python3Packages.pip
    python3Packages.requests
    python3Packages.virtualenv
    ripgrep
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
    zellij
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
    ];
  };

  environment.shells = [ pkgs.fish ];
  programs.fish.shellAliases = {
    ll = "eza --long --header --group-directories-first --icons=auto --group";
    la = "eza --long --header --group-directories-first --icons=auto --group --all --all";
  };

  hardware.enableRedistributableFirmware = true;

  services.openssh.enable = true;
  security.sudo.enable = true;

  system.stateVersion = "25.11";
}
