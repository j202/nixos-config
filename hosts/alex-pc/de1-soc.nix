# vim: set ft=nix ts=2 sw=2 sts=2 et:
# DE1-SoC dev board on the onboard NIC, NATed behind the PC. Drop this file
# from the host's imports to remove the setup.
_: {
  networking = {
    # NM's "shared" mode runs dnsmasq (DHCP+DNS) and masquerades out via the uplink
    networkmanager.ensureProfiles.profiles.de1-soc = {
      connection = {
        id = "de1-soc";
        type = "ethernet";
        interface-name = "enp5s0";
      };
      ipv4.method = "shared";
      ipv6.method = "ignore";
    };

    # NM's dnsmasq sits behind the NixOS firewall, so DHCP and DNS must be let in
    firewall.interfaces.enp5s0 = {
      allowedUDPPorts = [
        53
        67
      ];
      allowedTCPPorts = [ 53 ];
    };

    hosts."10.42.0.50" = [ "de1-soc" ];
  };

  # Pin the board's lease by the hostname it sends, since its MAC is derived
  # from the SD card and can change
  environment.etc."NetworkManager/dnsmasq-shared.d/de1-soc.conf".text = ''
    dhcp-host=de1-soc,10.42.0.50
  '';
}
