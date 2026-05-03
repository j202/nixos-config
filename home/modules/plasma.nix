# vim: set ft=nix ts=2 sw=2 sts=2 et:
# KDE Plasma catppuccin home-manager config — color scheme, Plasma style, icons, cursors.
{ config, pkgs, ... }:
{
  home.packages = [
    (pkgs.catppuccin-kde.override {
      flavour = [ "mocha" ];
      accents = [ "mauve" ];
      winDecStyles = [ "modern" ];
    })
    pkgs.papirus-icon-theme
    pkgs.kdePackages.qtstyleplugin-kvantum
  ];

  # Kvantum Qt style (catppuccin theme applied via catppuccin.kvantum)
  qt = {
    enable = true;
    style.name = "kvantum";
  };
  catppuccin.kvantum.enable = true;

  # Catppuccin cursor theme
  catppuccin.cursors.enable = true;

  # Apply color scheme, icons, and file dialog preferences declaratively.
  # Note: KDE also writes to this file; any System Settings changes will be
  # overwritten on the next rebuild.
  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=CatppuccinMochaMauve

    [Icons]
    Theme=Papirus-Dark

    [KDE]
    LookAndFeelPackage=Catppuccin-Mocha-Mauve

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
}
