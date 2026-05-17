# vim: set ft=nix ts=2 sw=2 sts=2 et:
{ ... }:
{
  # services.kanshi runs as a systemd user service and starts automatically
  # via graphical-session.target — no exec-once entry needed.
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "dual";
        profile.outputs = [
          {
            criteria = "AOC AG405UXC XYCQ2JA000267"; # cspell:ignore XYCQ2JA000267
            mode = "3440x1440@144Hz";
            position = "0,1080";
            status = "enable";
          }
          {
            criteria = "HP Inc. HP E24u G4 CN4139185F";
            mode = "1920x1080@60Hz";
            position = "720,0";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "single";
        profile.outputs = [
          {
            criteria = "*";
            status = "enable";
          }
        ];
      }
    ];
  };
}
