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

  # Embed full color definitions inline so Plasma 6 picks them up without needing
  # to write back to kdeglobals (which it can't, since this is a read-only symlink).
  # ColorScheme= alone is not sufficient for QML/Kirigami apps.
  xdg.configFile."kdeglobals" = {
    force = true;
    text = ''
      [ColorEffects:Disabled]
      Color=30,30,46
      ColorAmount=0.30000000000000004
      ColorEffect=2
      ContrastAmount=0.1
      ContrastEffect=0
      IntensityAmount=-1
      IntensityEffect=0

      [ColorEffects:Inactive]
      ChangeSelectionColor=true
      Color=30,30,46
      ColorAmount=0.5
      ColorEffect=3
      ContrastAmount=0
      ContrastEffect=0
      Enable=true
      IntensityAmount=0
      IntensityEffect=0

      [Colors:Button]
      BackgroundAlternate=203,166,247
      BackgroundNormal=49,50,68
      DecorationFocus=203,166,247
      DecorationHover=49,50,68
      ForegroundActive=250,179,135
      ForegroundInactive=166,173,200
      ForegroundLink=203,166,247
      ForegroundNegative=243,139,168
      ForegroundNeutral=249,226,175
      ForegroundNormal=205,214,244
      ForegroundPositive=166,227,161
      ForegroundVisited=203,166,247

      [Colors:Complementary]
      BackgroundAlternate=17,17,27
      BackgroundNormal=24,24,37
      DecorationFocus=203,166,247
      DecorationHover=49,50,68
      ForegroundActive=250,179,135
      ForegroundInactive=166,173,200
      ForegroundLink=203,166,247
      ForegroundNegative=243,139,168
      ForegroundNeutral=249,226,175
      ForegroundNormal=205,214,244
      ForegroundPositive=166,227,161
      ForegroundVisited=203,166,247

      [Colors:Header]
      BackgroundAlternate=17,17,27
      BackgroundNormal=24,24,37
      DecorationFocus=203,166,247
      DecorationHover=49,50,68
      ForegroundActive=250,179,135
      ForegroundInactive=166,173,200
      ForegroundLink=203,166,247
      ForegroundNegative=243,139,168
      ForegroundNeutral=249,226,175
      ForegroundNormal=205,214,244
      ForegroundPositive=166,227,161
      ForegroundVisited=203,166,247

      [Colors:Selection]
      BackgroundAlternate=203,166,247
      BackgroundNormal=203,166,247
      DecorationFocus=203,166,247
      DecorationHover=49,50,68
      ForegroundActive=250,179,135
      ForegroundInactive=24,24,37
      ForegroundLink=203,166,247
      ForegroundNegative=243,139,168
      ForegroundNeutral=249,226,175
      ForegroundNormal=17,17,27
      ForegroundPositive=166,227,161
      ForegroundVisited=203,166,247

      [Colors:Tooltip]
      BackgroundAlternate=27,25,35
      BackgroundNormal=30,30,46
      DecorationFocus=203,166,247
      DecorationHover=49,50,68
      ForegroundActive=250,179,135
      ForegroundInactive=166,173,200
      ForegroundLink=203,166,247
      ForegroundNegative=243,139,168
      ForegroundNeutral=249,226,175
      ForegroundNormal=205,214,244
      ForegroundPositive=166,227,161
      ForegroundVisited=203,166,247

      [Colors:View]
      BackgroundAlternate=24,24,37
      BackgroundNormal=30,30,46
      DecorationFocus=203,166,247
      DecorationHover=49,50,68
      ForegroundActive=250,179,135
      ForegroundInactive=166,173,200
      ForegroundLink=203,166,247
      ForegroundNegative=243,139,168
      ForegroundNeutral=249,226,175
      ForegroundNormal=205,214,244
      ForegroundPositive=166,227,161
      ForegroundVisited=203,166,247

      [Colors:Window]
      BackgroundAlternate=17,17,27
      BackgroundNormal=24,24,37
      DecorationFocus=203,166,247
      DecorationHover=49,50,68
      ForegroundActive=250,179,135
      ForegroundInactive=166,173,200
      ForegroundLink=203,166,247
      ForegroundNegative=243,139,168
      ForegroundNeutral=249,226,175
      ForegroundNormal=205,214,244
      ForegroundPositive=166,227,161
      ForegroundVisited=203,166,247

      [General]
      ColorScheme=CatppuccinMochaMauve
      Name=Catppuccin Mocha Mauve
      accentActiveTitlebar=false
      shadeSortColumn=true

      [Icons]
      Theme=Papirus-Dark

      [KDE]
      LookAndFeelPackage=Catppuccin-Mocha-Mauve
      contrast=4
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

      [WM]
      activeBackground=30,30,46
      activeBlend=205,214,244
      activeForeground=205,214,244
      inactiveBackground=17,17,27
      inactiveBlend=166,173,200
      inactiveForeground=166,173,200
    '';
  };

  # Plasma panel/shell theme. "breeze-dark" follows the colour scheme for a dark panel.
  # Without this, the panel defaults to "default" (Breeze Light).
  xdg.configFile."plasmarc" = {
    force = true;
    text = ''
      [Theme]
      name=breeze-dark
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
