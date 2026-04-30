# vim: set ft=nix ts=2 sw=2 sts=2 et:
# ASRock Z790 PG Lightning / Intel i7-13700K / AMD Radeon RX 7900 XT
{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
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

  # Hyprland + greetd
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      user = "greeter";
    };
  };

  security.pam.services.hyprlock = { };

  # Electron/Chromium apps use Wayland natively
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # PipeWire — modern audio stack, with 32-bit ALSA for games
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Extra groups beyond the common wheel+networkmanager
  users.users.alex.extraGroups = [ "wheel" "networkmanager" "audio" "video" ];

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  programs.gamemode.enable = true;
  programs.mangohud.enable = true;
  programs.gamescope.enable = true;

  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
  };

  hardware.xpadneo.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  # Wayland-specific and PC-only packages
  environment.systemPackages = with pkgs; [
    grim        # Wayland screenshot
    nvme-cli    # NVMe drive health
    slurp       # Wayland region selector
    wl-clipboard
  ];

  system.stateVersion = "25.11";
}
