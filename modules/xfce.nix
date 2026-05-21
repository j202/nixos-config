# vim: set ft=nix ts=2 sw=2 sts=2 et:
# XFCE desktop with LightDM and PulseAudio.
# Video driver is host-specific — set services.xserver.videoDrivers in the host config.
{
  pkgs,
  ...
}:
{
  services = {
    xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.xfce.enable = true;
    };
    pulseaudio.enable = true;
    pipewire = {
      enable = false;
      pulse.enable = false;
    };
  };

  environment.systemPackages = [ pkgs.xfce.xfce4-clipman-plugin ];

  environment.etc."xdg/autostart/xfce4-clipman.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Xfce4 Clipman
    Exec=xfce4-clipman
    OnlyShowIn=XFCE;
  '';
}
