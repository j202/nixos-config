# vim: set ft=nix ts=2 sw=2 sts=2 et:
# KDE Plasma catppuccin home-manager config — color scheme, Plasma style, icons, cursors.
{
  lib,
  pkgs,
  ...
}:
let
  catppuccin-kde = pkgs.catppuccin-kde.override {
    flavour = [ "mocha" ];
    accents = [ "mauve" ];
    winDecStyles = [ "modern" ];
  };

  colorSchemeFile = "${catppuccin-kde}/share/color-schemes/CatppuccinMochaMauve.colors";

  wallpaper = pkgs.fetchurl {
    url = "https://assets.alex-sh.co.uk/wallpaper/night-sky-space-colorful-scenery-4k-wallpaper-uhdpaper.com.jpg";
    hash = "sha256-B8GwZ/n0pty4zvsWiEeXy8SMrlWU5gzBAP4MROmWfq4=";
  };

  # Plasma 6 QML/Kirigami apps need color values inline in kdeglobals — the
  # ColorScheme= cascade alone is not sufficient.  Generate the file from the
  # package's .colors file so the values stay in sync with catppuccin-kde updates.
  kdeglobalsFile = pkgs.runCommand "kdeglobals" { } ''
    cat ${colorSchemeFile} > $out
    cat >> $out <<'EOF'

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
    EOF
  '';
in
{
  home = {
    packages = [
      catppuccin-kde
      pkgs.papirus-icon-theme
      pkgs.kdePackages.qtstyleplugin-kvantum
    ];

    # Alt+Space → rofi via KDE global shortcuts.
    # kglobalacceld nests desktop-file launchers under [services][name.desktop].
    # Using two --group flags writes directly to that nested path.
    # Also disables krunner's Alt+Space so it doesn't compete.
    # Takes effect next login (kwriteconfig6 is pure file I/O, no D-Bus needed).
    activation.rofiShortcut = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
        --file kglobalshortcutsrc \
        --group "services" --group "rofi-drun.desktop" \
        --key "_launch" "Alt+Space"
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
        --file kglobalshortcutsrc \
        --group "org.kde.krunner.desktop" \
        --key "_launch" "none,Alt+Space,KRunner"
    '';
  };

  # Link all catppuccin-kde assets into ~/.local/share so KDE can discover them.
  # home.packages alone doesn't put them on KDE's XDG search path.
  xdg = {
    dataFile = {
      "plasma/look-and-feel/Catppuccin-Mocha-Mauve".source =
        "${catppuccin-kde}/share/plasma/look-and-feel/Catppuccin-Mocha-Mauve";
      "color-schemes/CatppuccinMochaMauve.colors".source =
        "${catppuccin-kde}/share/color-schemes/CatppuccinMochaMauve.colors";
      "aurorae/themes/CatppuccinMocha-Modern".source =
        "${catppuccin-kde}/share/aurorae/themes/CatppuccinMocha-Modern";
    };

    configFile = {
      # kdeglobals: inline colour values for Plasma 6 QML/Kirigami apps
      "kdeglobals" = {
        force = true;
        source = kdeglobalsFile;
      };
      # Plasma panel/shell theme. "default" follows the active colour scheme.
      # With catppuccin colours now inline in kdeglobals, the panel renders in
      # Colors:Complementary (#181824) rather than the Breeze Dark grey.
      "plasmarc" = {
        force = true;
        text = ''
          [Theme]
          name=default
        '';
      };
      # Lock screen theme and wallpaper.
      "kscreenlockerrc" = {
        force = true;
        text = ''
          [Daemon]
          Timeout=30

          [Greeter]
          Theme=Catppuccin-Mocha-Mauve
          WallpaperPlugin=org.kde.image

          [Greeter][Wallpaper][org.kde.image][General]
          Image=${wallpaper}
        '';
      };
    };

    # Desktop entry for rofi — KDE needs a .desktop file to register the global shortcut.
    desktopEntries.rofi-drun = {
      name = "Rofi";
      exec = "${pkgs.rofi}/bin/rofi -show drun";
      noDisplay = true;
    };
  };

  # Kvantum Qt style (catppuccin theme applied via catppuccin.kvantum)
  qt = {
    enable = true;
    style.name = "kvantum";
  };

  catppuccin = {
    kvantum.enable = true;
    cursors.enable = true;
  };
}
