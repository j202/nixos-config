# vim: set ft=nix ts=2 sw=2 sts=2 et:
# LAN-only file sync — used to pull the phone's camera roll into ~/Pictures.
# GUI stays on localhost:8384 (Syncthing's fixed default), unreachable from
# the network; sync/discovery ports are opened for the phone to find this PC.
_: {
  services.syncthing = {
    enable = true;
    user = "alex";
    group = "users";
    dataDir = "/home/alex";
    configDir = "/home/alex/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "127.0.0.1:8384";

    # Both default to true, which deletes any device/folder not declared
    # here on every rebuild — device pairing and folder shares are set up
    # via the GUI (they're local runtime state, not committed), so leave
    # them alone instead of wiping them out from under it.
    overrideDevices = false;
    overrideFolders = false;

    # Fail closed instead of silently falling back to the internet: only
    # sync when both devices are on the same LAN.
    settings.options = {
      localAnnounceEnabled = true;
      globalAnnounceEnabled = false;
      relaysEnabled = false;
      natEnabled = false;
    };
  };
}
