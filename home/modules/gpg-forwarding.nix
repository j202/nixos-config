# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Two-way gpg/ssh agent forwarding between the desktop hosts. Each host's
# ssh_config forwards its own agent to the other (see secrets/ssh_config.age),
# so a passphrase prompt raised from an ssh session lands on the machine
# actually being sat at, as a popup, instead of fighting the terminal.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Popup when the agent has a display, curses otherwise (headless).
  pinentry-auto = pkgs.writeShellScriptBin "pinentry" ''
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
      exec ${pkgs.pinentry-qt}/bin/pinentry "$@"
    else
      exec ${pkgs.pinentry-curses}/bin/pinentry "$@"
    fi
  '';
in
{
  services.gpg-agent = {
    pinentry.package = lib.mkForce pinentry-auto;
    enableExtraSocket = true;
  };

  # GNUPGHOME for ssh sessions whose client RemoteForwards its gpg-agent
  # extra socket to S.gpg-agent here. 0700 or gpg refuses it. no-autostart:
  # a stale forward must fail, not start an empty local agent here.
  systemd.user.tmpfiles.rules = [
    "d %h/.gnupg-forwarded 0700 - - -"
    "f %h/.gnupg-forwarded/gpg.conf 0600 - - - no-autostart"
  ];

  # Use a forwarded gpg-agent when the ssh client provided one, so prompts
  # appear on the client; this machine's own agent is untouched. mkAfter:
  # home-manager's updatestartuptty must reach the local agent, not the
  # forwarded one.
  programs.fish.interactiveShellInit = lib.mkAfter ''
    if set -q SSH_CONNECTION
      set -l fwd ~/.gnupg-forwarded
      if gpg-connect-agent --homedir $fwd --no-autostart /bye >/dev/null 2>&1
        if not test -s $fwd/pubring.kbx
          gpg --export ${config.programs.git.settings.user.signingKey} | gpg --homedir $fwd --import --quiet
        end
        set -gx GNUPGHOME $fwd
        # A tty here means nothing to the client's pinentry; unset, it
        # falls back to the client's own terminal.
        set -e GPG_TTY
      end
    end
  '';
}
