# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  config,
  pkgs,
  ...
}:
let
  flavor = config.catppuccin.flavor;
  accent = config.catppuccin.accent;
in
{
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "menu:";

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-${flavor}-${accent}-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = flavor;
        accents = [ accent ];
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        inherit flavor accent;
      };
    };
    gtk4.theme = config.gtk.theme;
    gtk3.extraConfig = {
      gtk-decoration-layout = "menu:";
    };
    gtk4.extraConfig = {
      gtk-decoration-layout = "menu:";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "kvantum";
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  catppuccin.kvantum.enable = true;
}
