# vim: set ft=nix ts=2 sw=2 sts=2 et:
# KDE Plasma catppuccin home-manager config — color scheme, Plasma style, icons, cursors.
{ config, pkgs, ... }:
let
  catppuccin-kde = pkgs.catppuccin-kde.override {
    flavour = [ "mocha" ];
    accents = [ "mauve" ];
    winDecStyles = [ "modern" ];
  };
in
{
  home.packages = [
    catppuccin-kde
    pkgs.papirus-icon-theme
    pkgs.kdePackages.qtstyleplugin-kvantum
  ];

  # Link all catppuccin-kde assets into ~/.local/share so KDE can discover them.
  # home.packages alone doesn't put them on KDE's XDG search path.
  xdg.dataFile = {
    "plasma/look-and-feel/Catppuccin-Mocha-Mauve".source =
      "${catppuccin-kde}/share/plasma/look-and-feel/Catppuccin-Mocha-Mauve";
    "color-schemes/CatppuccinMochaMauve.colors".source =
      "${catppuccin-kde}/share/color-schemes/CatppuccinMochaMauve.colors";
    "aurorae/themes/CatppuccinMocha-Modern".source =
      "${catppuccin-kde}/share/aurorae/themes/CatppuccinMocha-Modern";
  };

  # Kvantum Qt style (catppuccin theme applied via catppuccin.kvantum)
  qt = {
    enable = true;
    style.name = "kvantum";
  };
  catppuccin.kvantum.enable = true;

  # Catppuccin cursor theme
  catppuccin.cursors.enable = true;

  xdg.configFile."kdeglobals" = {
    force = true;
    text = ''
      [General]
      ColorScheme=CatppuccinMochaMauve

      [Icons]
      Theme=Papirus-Dark

      [KDE]
      LookAndFeelPackage=Catppuccin-Mocha-Mauve
      widgetStyle=kvantum

      [KFileDialog Settings]
      Allow Expansion=false
      Automatically select filename extension=true
      Breadcrumb Navigation=true
      Decoration position=2
      Show Full Path=false
      Show Inline Previews=true
      Show Preview=false
      Show Speedbar=true
      Show hidden files=true
      Sort by=Name
      Sort directories first=true
      Sort hidden files last=false
      Sort reversed=false
      Speedbar Width=140
      View Style=DetailTree
    '';
  };

  # Lock screen theme.
  xdg.configFile."kscreenlockerrc" = {
    force = true;
    text = ''
      [Daemon]
      Timeout=30

      [Greeter]
      Theme=Catppuccin-Mocha-Mauve
    '';
  };
}
