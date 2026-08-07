# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Universal baseline — imported by every host.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    useXkbConfig = true;
  };

  services = {
    xserver.xkb = {
      layout = "gb";
      options = "ctrl:nocaps";
    };
    fstrim.enable = true;
    fwupd.enable = true;
    smartd = {
      enable = true;
      notifications.systembus-notify.enable = true;
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };

  users.users.alex = {
    isNormalUser = true;
    extraGroups = lib.mkDefault [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [ tree ];
    shell = pkgs.fish;
    # SSH auth via the RSA authentication subkey of the alex-1330 GPG key
    # (gpg-agent enableSshSupport) rather than a dedicated SSH keypair.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1ODlut1FSezgq3BO42P/GgGeC+h6oPLnwsE9VXv+AvUPSpTGglRnhb16fgFJA8UlyhcARaPsK7pg2ywwHw1RLDEo2SnTwjHxVfJkfi1rXS/O4/wNz7SD478OEPcImgOyHpxQyeVKa+JtF+MnjftKdgoP3/WXjD4SKdmmblZpPHFgbiNZWY/ySIRgKen5hjAHrsaVP/c3/E2rUcQyC7O096Hw70p3EScU9Ea46cBx0KzBLvZhjYyu5J0jvY1N4+Eakzb1eaONCWWj75GdqvSP4Y3wuQHV7e2MurVxr5saEG3w9pO8PZ9dQk6gWtQYOApQrk3GVHgTW9210Ys6QywNp6xLz/i9gvMoN2Lkw/broQwrwYxynJiDxo/hw3UMRIJghc2utX/f7imfRE5J4Ynxwd7QXQv+w5af/itHqArOeglHirNfQUu7sN6E7mUORvBVo9jokmpnLzpIjqwru5Dv8v6lNvt1VmOYsVEXiuitZyDqvAYA48CwmSQdKAi0smd52fdgEFVf/I8YnD2b/fH0nHvmpkx7NVApGdiEPrCUsNdBlZu5TWKAKvGNQHenfjCuzM8p9NxaV8YHAoB/SYB3KbsKmh7BscdRN99dJDTSEehZKWRTUPlFRKkdWZ+PITS9Spf1Iguz1M/v44vuY+to85Rst6KLergY7SaQgMz0hvw== openpgp:0x4C145B5F"
    ];
  };

  programs = {
    fish = {
      enable = true;
      shellAliases = {
        ll = "eza --long --header --group-directories-first --icons=auto --group";
        la = "eza --long --header --group-directories-first --icons=auto --group --all --all";
      };
    };
    nix-ld.enable = true;
    mtr.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    netrc-file = config.age.secrets.netrc.path;
    trusted-users = [
      "root"
      "alex"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://noctalia.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  age.identityPaths = [ "/etc/age/key" ];
  age.secrets = {
    netrc = {
      file = ../secrets/netrc.age;
      mode = "0400";
    };
    # The encrypted secret is canonical, not ~/.ssh/config itself — edit via
    # `cd secrets && sudo -E agenix -e ssh_config.age -i /etc/age/key`, then
    # switch. Keeps this repo (public) from ever holding hostnames/usernames
    # in plaintext.
    ssh-config = {
      file = ../secrets/ssh_config.age;
      path = "/home/alex/.ssh/config";
      owner = "alex";
      mode = "0600";
    };
  };

  hardware.enableRedistributableFirmware = true;
  security.sudo.enable = true;

  environment.shells = [ pkgs.fish ];

  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    dig
    dysk
    eza
    fastfetch
    fd
    file
    fish
    fzf
    gdu
    git
    gnupg
    htop
    jq
    neovim
    nmap
    pciutils
    pinentry-qt
    pv
    rclone
    ripgrep
    rsync
    tcpdump
    tmux
    unzip
    usbutils
    vim
    wget
    yazi
    zellij
    zip
  ];
}
