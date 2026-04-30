# vim: set ft=nix ts=2 sw=2 sts=2 et:
# ASRock Z790 PG Lightning / Intel i7-13700K / AMD Radeon RX 7900 XT
{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # UEFI / systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "alex-pc";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # AMD GPU — amdgpu driver, with 32-bit support for Wine/Steam
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    xkb = {
      layout = "gb";
      options = "ctrl:nocaps";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # KDE Plasma 6 on Wayland
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # PipeWire (modern audio stack)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
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

  services.openssh.enable = true;
  security.sudo.enable = true;

  system.stateVersion = "25.11";
}
