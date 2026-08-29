# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Dell XPS M1330 — old hardware, resource-constrained
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/dev.nix
    ../../modules/xfce.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = false;
      configurationLimit = 10;
    };
    # Limit RAM to 2 GB — hardware cap on this machine
    kernelParams = [ "mem=2G" ];
  };

  networking.hostName = "xpsm1330";

  # Compressed RAM swap, preferred over the disk swap partition below it —
  # much less thrashing than disk swap on this 2 GB machine's old storage.
  zramSwap.enable = true;

  services.xserver.videoDrivers = [ "nouveau" ];

  # Limit parallel builds — only 2 GB RAM
  nix.settings.max-jobs = 1;

  programs.firefox.enable = true;

  system.stateVersion = "25.11";
}
