# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Recipients for each secret. Add new machine host keys here when needed.
# The alex key is a personal age key stored in the password manager —
# use it with: agenix -e <secret> -i /etc/age/key
let
  alex = "age1hntvavggck24l9pr35c773eeulcqg925qxssaamty7spfs06yvaq5ek8nn";
in
{
  "netrc.age".publicKeys = [ alex ];
  "ssh_config.age".publicKeys = [ alex ];
}
