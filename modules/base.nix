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
    openssh.enable = true;
  };

  users.users.alex = {
    isNormalUser = true;
    extraGroups = lib.mkDefault [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [ tree ];
    shell = pkgs.fish;
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
  # vesktop pins electron_40, which upstream nixpkgs now marks EOL/insecure
  # (any electron <41 is flagged). Pinned to this exact version deliberately:
  # once vesktop bumps its electron dependency, this string stops matching
  # and the build fails again, forcing this line to be revisited/removed.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
  ];
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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
  age.secrets.netrc = {
    file = ../secrets/netrc.age;
    mode = "0400";
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
