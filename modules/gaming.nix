# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Gaming stack — Steam, performance tools, controller support.
{
  pkgs,
  ...
}:
{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    gamemode.enable = true;
    gamescope.enable = true;
    corectrl.enable = true;
  };
  # lutris's FHS env still bundles gtk2, which nixpkgs now marks broken.
  # Drop once lutris stops depending on it.
  nixpkgs.config.problems.handlers."gtk+".broken = "warn";

  hardware.amdgpu.overdrive.enable = true;

  hardware.xpadneo.enable = true;

  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  environment.systemPackages = with pkgs; [
    mangohud
    vkbasalt
    wineWow64Packages.waylandFull
    lutris
    ludusavi
    winetricks
  ];
}
