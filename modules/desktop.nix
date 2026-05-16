# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Common desktop services and packages — imported by all hosts with a display.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.libinput.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.roboto-mono
      nerd-fonts.symbols-only
      noto-fonts-color-emoji
    ];
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    ffmpeg
    mpv
    pavucontrol
    playerctl
  ];
}
