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
  };
}
