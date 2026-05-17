# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Bluetooth hardware and management applet.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # After S3 resume every fresh bluetoothd fails "set default system config"
  # because the kernel MGMT interface isn't ready yet; a 3-second internal
  # timeout then fires and powers hci0 back off. By 10 seconds the MGMT
  # interface is stable, so "power on" triggers a fresh init that completes.
  # Use systemd-run to schedule the command as a transient timer unit that
  # lives outside the hook's cgroup and won't be killed when the hook exits.
  environment.etc."systemd/system-sleep/bluetooth-resume" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      [ "$1" = "post" ] || exit 0
      ${pkgs.systemd}/bin/systemd-run --no-block --on-active=10s \
        ${pkgs.bluez}/bin/bluetoothctl power on
    '';
  };
}
