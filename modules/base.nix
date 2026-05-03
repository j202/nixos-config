# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Universal baseline — imported by every host.
{ config, lib, pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "ter-v16n";
    useXkbConfig = true;
  };

  services.xserver.xkb = {
    layout = "gb";
    options = "ctrl:nocaps";
  };

  services.fstrim.enable = true;
  services.openssh.enable = true;

  users.users.alex = {
    isNormalUser = true;
    extraGroups = lib.mkDefault [ "wheel" "networkmanager" ];
    packages = with pkgs; [ tree ];
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "eza --long --header --group-directories-first --icons=auto --group";
      la = "eza --long --header --group-directories-first --icons=auto --group --all --all";
    };
  };

  programs.nix-ld.enable = true;
  programs.mtr.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.enableRedistributableFirmware = true;
  security.sudo.enable = true;

  environment.shells = [ pkgs.fish ];

  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    dysk
    eza
    fd
    file
    fish
    fzf
    git
    gnupg
    htop
    jq
    neovim
    pciutils
    pinentry-qt
    ripgrep
    rsync
    tmux
    terminus_font
    unzip
    usbutils
    vim
    wget
    yazi
    zellij
    zip
  ];
}
