# vim: set ft=nix ts=2 sw=2 sts=2 et:
# ASRock Z790 PG Lightning / Intel i7-13700K / AMD Radeon RX 7900 XT
{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/dev.nix
    ../../modules/hyprland.nix
    ../../modules/pipewire.nix
    ../../modules/gaming.nix
    ../../modules/bluetooth.nix
  ];

  # UEFI / systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Keep kernel off swap — 32 GB RAM means we never want to swap
  boot.kernel.sysctl."vm.swappiness" = 10;

  networking.hostName = "alex-pc";

  # AMD GPU — amdgpu driver, 32-bit for Wine/Steam
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.cpu.intel.updateMicrocode = true;

  # Extra groups beyond the common wheel+networkmanager
  users.users.alex.extraGroups = [ "wheel" "networkmanager" "audio" "video" ];

  # Wayland-specific and PC-only packages
  programs.brave.enable = true;

  environment.systemPackages = with pkgs; [
    nvme-cli
    obsidian
    spotify
  ];

  system.stateVersion = "25.11";
}
