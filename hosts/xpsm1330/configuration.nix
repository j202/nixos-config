# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Dell XPS M1330 — old hardware, resource-constrained
{ config, ... }:
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

  # Offload builds to alex-pc instead of building locally on this 2 GB
  # machine. Hostname/user/host-key live only in the encrypted machines
  # file (never in git-tracked source — this repo is public) alongside a
  # dedicated keypair used solely for this, unrelated to interactive SSH.
  age.secrets = {
    nix-build-ssh-key = {
      file = ../../secrets/nix_build_ssh_key.age;
      mode = "0400";
      owner = "root";
    };
    nix-build-machines = {
      file = ../../secrets/nix_build_machines.age;
      mode = "0400";
      owner = "root";
    };
  };
  nix = {
    distributedBuilds = true;
    settings = {
      # Limit parallel local builds — only 2 GB RAM
      max-jobs = 1;
      builders = "@${config.age.secrets.nix-build-machines.path}";
      builders-use-substitutes = true;
    };
  };

  programs.firefox.enable = true;

  system.stateVersion = "25.11";
}
