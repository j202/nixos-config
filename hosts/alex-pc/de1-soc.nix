# vim: set ft=nix ts=2 sw=2 sts=2 et:
# DE1-SoC dev board on the onboard NIC, NATed behind the PC, netbooted over
# TFTP (U-Boot PXE + kernel) and NFS (root fs). Drop this file from the host's
# imports to remove the setup.
{ lib, pkgs, ... }:
{
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

  systemd = {
    services = {
      # mountd starts before nfs-server's `exportfs -r` creates etab, and exits if
      # it is missing
      nfs-mountd.preStart = ''
        touch /var/lib/nfs/etab
      '';

      de1-soc-rootfs-apply = {
        description = "Apply a netboot root filesystem deploy from the inbox";
        restartIfChanged = false;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "de1-soc-rootfs-apply";
              runtimeInputs = [
                pkgs.coreutils
                pkgs.gnutar
              ];
              text = ''
                inbox=/srv/de1-soc/inbox
                export_dir=/srv/de1-soc/rootfs

                cd "$inbox"
                rm -f ready status

                if [ ! -f rootfs.tar ] && [ ! -f layers.tar ]; then
                  echo "nothing to apply: no rootfs.tar or layers.tar" >&2
                  exit 1
                fi

                if [ -f rootfs.tar ]; then
                  rm -rf "$export_dir.new"
                  mkdir "$export_dir.new"
                  tar --numeric-owner -xpf rootfs.tar -C "$export_dir.new"
                  rm -rf "$export_dir.old"
                  if [ -d "$export_dir" ]; then
                    mv "$export_dir" "$export_dir.old"
                  fi
                  mv "$export_dir.new" "$export_dir"
                fi

                if [ -f layers.tar ]; then
                  tar --numeric-owner -xpf layers.tar -C "$export_dir"
                fi
              '';
            }
          );
          # Outside the sandbox: exportfs writes /var/lib/nfs and talks to the kernel.
          ExecStartPost = "+${pkgs.nfs-utils}/bin/exportfs -r";
          # Runs on failure too, so the script always gets an answer.
          ExecStopPost = pkgs.writeShellScript "de1-soc-rootfs-apply-status" ''
            cd /srv/de1-soc/inbox
            rm -f rootfs.tar layers.tar
            if [ "$SERVICE_RESULT" = success ]; then
              echo ok >status
            else
              echo failed >status
            fi
          '';

          # A hostile tar or a planted symlink in the inbox can only reach /srv/de1-soc.
          ProtectSystem = "strict";
          ReadWritePaths = "/srv/de1-soc";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateNetwork = true;
          NoNewPrivileges = true;
        };
      };
    };

    # The tftp dir and the inbox are alex's so a script can write them without
    # sudo (dnsmasq runs as nobody and only reads tftp). The rootfs needs root
    # ownership for no_root_squash, so the apply service fills it from the
    # inbox.
    tmpfiles.rules = [
      "d /srv/de1-soc 0755 root root - -"
      "d /srv/de1-soc/tftp 0755 alex users - -"
      "d /srv/de1-soc/inbox 0700 alex users - -"
      "d /srv/de1-soc/rootfs 0755 root root - -"
    ];

    # Rootless netboot deploy: the deploy script puts rootfs.tar (whole tree,
    # swapped in; the old one is kept as rootfs.old) and/or layers.tar (extracted
    # over it) in the inbox, then touches `ready`. The service applies them as
    # root and writes `status` (ok/failed) for the script to read.
    paths.de1-soc-rootfs-apply = {
      wantedBy = [ "paths.target" ];
      pathConfig.PathExists = "/srv/de1-soc/inbox/ready";
    };
  };
}
