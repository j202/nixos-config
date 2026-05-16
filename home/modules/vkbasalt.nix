# vim: set ft=nix ts=2 sw=2 sts=2 et:
# vkBasalt post-processing layer config.
# Enable per game with ENABLE_VKBASALT=1 in Steam launch options.
{ ... }:
{
  xdg.configFile."vkBasalt/vkBasalt.conf".text = ''
    effects = cas

    # Sharpening strength 0.0 (none) – 1.0 (maximum). 0.4 is a good starting point.
    cas_sharpness = 0.4

    depthCapture = off
  '';
}
