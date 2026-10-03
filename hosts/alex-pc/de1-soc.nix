# vim: set ft=nix ts=2 sw=2 sts=2 et:
# DE1-SoC dev board on the onboard NIC, NATed behind the PC, netbooted over
# TFTP (U-Boot PXE + kernel) and NFS (root fs). Drop this file from the host's
# imports to remove the setup.
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

    # NM's dnsmasq sits behind the NixOS firewall, so DHCP, DNS and TFTP must be
    # let in. NFS (2049) is writable and unauthenticated, so it stays on this
    # interface only.
    firewall.interfaces.enp5s0 = {
      allowedUDPPorts = [
        53
        67
        69
      ];
      allowedTCPPorts = [
        53
        2049
      ];
    };

    hosts."10.42.0.50" = [ "de1-soc" ];
  };

  # Pin the board's lease by the hostname it sends, since its MAC is derived
  # from the SD card and can change. Reflashing changes the client-ID, so
  # identify by MAC only, and keep the lease short so a stale one clears fast.
  environment.etc."NetworkManager/dnsmasq-shared.d/de1-soc.conf".text = ''
    dhcp-ignore-clid
    dhcp-host=de1-soc,10.42.0.50,5m

    # Netboot: dhcp-boot only makes dnsmasq send next-server (the file name is
    # never fetched), and the kernel takes its NFS server from next-server.
    enable-tftp
    tftp-root=/srv/de1-soc/tftp
    dhcp-boot=de1-soc.pxe,,10.42.0.1
    dhcp-option=option:root-path,/srv/de1-soc/rootfs,vers=4.2
  '';

  # NFSv4 only: the board needs just TCP 2049, no portmapper, mountd or lockd
  services.nfs = {
    settings.nfsd.vers3 = false;
    server = {
      enable = true;
      exports = ''
        /srv/de1-soc/rootfs 10.42.0.0/24(rw,sync,no_subtree_check,no_root_squash)
      '';
    };
  };

  # mountd starts before nfs-server's `exportfs -r` creates etab, and exits if
  # it is missing
  systemd.services.nfs-mountd.preStart = ''
    touch /var/lib/nfs/etab
  '';

  # The tftp dir is alex's so a script can write it without sudo (dnsmasq runs
  # as nobody and only reads it). The rootfs needs root ownership for no_root_squash.
  systemd.tmpfiles.rules = [
    "d /srv/de1-soc 0755 root root - -"
    "d /srv/de1-soc/tftp 0755 alex users - -"
    "d /srv/de1-soc/rootfs 0755 root root - -"
  ];
}
