# vim: set ft=nix ts=2 sw=2 sts=2 et:
# ASRock Z790 PG Lightning / Intel i7-13700K / AMD Radeon RX 7900 XT
{
  lib,
  pkgs,
  ...
}:
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
    ../../modules/vial.nix
  ];

  # UEFI / systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
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

  # The i40e (Intel X710 10GbE) driver hits a NULL pointer dereference in
  # i40e_clear_lan_tx_queue_context when NetworkManager re-raises the interface
  # after S3 resume, because tx_ring->desc is not yet allocated at that point.
  # Reloading the module before NM gets there avoids the race entirely.
  environment.etc."systemd/system-sleep/i40e-resume" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      [ "$1" = "post" ] || exit 0
      ${pkgs.kmod}/bin/modprobe -r i40e
      ${pkgs.kmod}/bin/modprobe i40e
    '';
  };

  # Extra groups beyond the common wheel+networkmanager
  users.users.alex.extraGroups = [
    "wheel"
    "networkmanager"
    "audio"
    "video"
  ];

  myConfig.vial = {
    enable = true;
    keyboards = [
      {
        name = "Corne v4";
        vendorId = "4653";
        productId = "0004";
      }
    ];
  };

  # Wayland-specific and PC-only packages
  environment.systemPackages = with pkgs; [
    brave
    nvme-cli
    obsidian
    proton-pass
    proton-pass-cli
    # Wrapper shadowing the real pass-cli binary. The linux-keyutils backend
    # stores the local encryption key in the session keyring (@s) with
    # user=view-only, so cross-thread reads fail with EACCES. Elevate to
    # user=full before each call. Check @u, @s, and @us — pass-cli uses @s.
    (lib.hiPrio (
      pkgs.writeShellApplication {
        name = "pass-cli";
        runtimeInputs = [ keyutils ];
        text = ''
          for keyring in @u @s @us; do
            keyctl list "$keyring" 2>/dev/null | while IFS= read -r line; do
              case "$line" in
                *ProtonPassCLI*)
                  id="''${line%%:*}"
                  id="''${id// /}"
                  [[ "$id" =~ ^[0-9]+$ ]] && keyctl setperm "$id" 0x3f3f0000 2>/dev/null || true
                  ;;
              esac
            done || true
          done
          exec ${proton-pass-cli}/bin/pass-cli "$@"
        '';
      }
    ))
    protonmail-desktop
    qutebrowser
    spotify
    vesktop
    vscode
  ];

  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/91dd4605-cdf2-4851-b6de-40639d3189a2";
    fsType = "btrfs";
    options = [
      "subvol=@games"
      "noatime"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /games 0755 alex users - -"
  ];

  system.stateVersion = "25.11";
}
