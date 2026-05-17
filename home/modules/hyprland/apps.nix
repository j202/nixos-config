# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  flavor = config.catppuccin.flavor;
  accent = config.catppuccin.accent;
  palette = builtins.fromJSON (
    builtins.readFile (config.catppuccin.sources.palette + "/palette.json")
  );
  c = builtins.mapAttrs (_: v: v.hex) palette.${flavor}.colors;
  flavorName =
    (lib.toUpper (lib.substring 0 1 flavor)) + (lib.substring 1 (lib.stringLength flavor - 1) flavor);
  imv-open = pkgs.writeShellScriptBin "imv-open" ''
    exec ${pkgs.imv}/bin/imv -n "$(basename "$1")" "$(dirname "$1")"
  '';
in
{
  home.packages = [ imv-open ];

  # ── imv (image viewer) ────────────────────────────────────────────────────

  xdg.desktopEntries.imv = {
    name = "imv";
    genericName = "Image Viewer";
    exec = "${imv-open}/bin/imv-open %f";
    mimeType = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/svg+xml"
      "image/bmp"
      "image/tiff"
      "image/heif"
      "image/avif"
      "image/jxl"
    ];
    categories = [
      "Graphics"
      "Viewer"
    ];
    noDisplay = false;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "inode/directory" = "thunar.desktop";
      "text/plain" = "org.gnome.gedit.desktop";
    };
  };

  # ── Hyprshell ─────────────────────────────────────────────────────────────

  xdg.configFile."hyprshell/styles.css".text =
    let
      rgba =
        name: alpha:
        let
          col = palette.${flavor}.colors.${name}.rgb;
        in
        "rgba(${toString col.r}, ${toString col.g}, ${toString col.b}, ${alpha})";
    in
    ''
      :root {
        --bg-window-color:     ${rgba "base" "0.92"};
        --bg-color:            ${rgba "surface0" "0.85"};
        --bg-color-hover:      ${rgba "surface1" "0.90"};
        --border-color:        ${rgba "surface2" "0.50"};
        --border-color-active: ${rgba accent "1.0"};
        --text-color:          ${rgba "text" "1.0"};
        --border-radius:       8px;
        --border-size:         2px;
      }
    '';

  xdg.configFile."hyprshell/config.ron".text = ''
    (
      version: 3,
      windows: (
        switch: (
          modifier: "alt",
          key: "Tab",
          filter_by: [],
          switch_workspaces: false,
          exclude_special_workspaces: "",
        ),
        switch_2: None,
        overview: None,
        scale: 8.5,
        items_per_row: 5,
      ),
    )
  '';

  # ── Gedit (GtkSourceView colour scheme) ──────────────────────────────────

  xdg.dataFile."libgedit-gtksourceview-300/styles/catppuccin-${flavor}.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <style-scheme id="catppuccin-${flavor}" _name="Catppuccin ${flavorName}" kind="dark">
      <_description>Soothing pastel theme</_description>

      <color name="rosewater" value="${c.rosewater}"/>
      <color name="flamingo"  value="${c.flamingo}"/>
      <color name="pink"      value="${c.pink}"/>
      <color name="mauve"     value="${c.mauve}"/>
      <color name="red"       value="${c.red}"/>
      <color name="maroon"    value="${c.maroon}"/>
      <color name="peach"     value="${c.peach}"/>
      <color name="yellow"    value="${c.yellow}"/>
      <color name="green"     value="${c.green}"/>
      <color name="teal"      value="${c.teal}"/>
      <color name="sky"       value="${c.sky}"/>
      <color name="sapphire"  value="${c.sapphire}"/>
      <color name="blue"      value="${c.blue}"/>
      <color name="lavender"  value="${c.lavender}"/>
      <color name="text"      value="${c.text}"/>
      <color name="subtext1"  value="${c.subtext1}"/>
      <color name="subtext0"  value="${c.subtext0}"/>
      <color name="overlay2"  value="${c.overlay2}"/>
      <color name="overlay1"  value="${c.overlay1}"/>
      <color name="overlay0"  value="${c.overlay0}"/>
      <color name="surface2"  value="${c.surface2}"/>
      <color name="surface1"  value="${c.surface1}"/>
      <color name="surface0"  value="${c.surface0}"/>
      <color name="base"      value="${c.base}"/>
      <color name="mantle"    value="${c.mantle}"/>
      <color name="crust"     value="${c.crust}"/>

      <style name="text"                    foreground="text"     background="base"/>
      <style name="selection"               foreground="crust"    background="mauve"/>
      <style name="cursor"                  foreground="rosewater"/>
      <style name="current-line"            background="surface0"/>
      <style name="line-numbers"            foreground="overlay1" background="mantle"/>
      <style name="current-line-number"     foreground="subtext1" background="mantle"/>
      <style name="draw-spaces"             foreground="surface1"/>
      <style name="bracket-match"           foreground="crust"    background="mauve"  bold="true"/>
      <style name="bracket-mismatch"        foreground="red"                          bold="true"/>
      <style name="right-margin"            foreground="surface0" background="surface0"/>
      <style name="search-match"            foreground="crust"    background="green"/>

      <style name="def:comment"             foreground="overlay0" italic="true"/>
      <style name="def:doc-comment"         foreground="overlay0" italic="true"/>
      <style name="def:doc-comment-element" foreground="overlay0"/>
      <style name="def:constant"            foreground="peach"/>
      <style name="def:string"              foreground="green"/>
      <style name="def:special-char"        foreground="pink"/>
      <style name="def:keyword"             foreground="mauve"/>
      <style name="def:statement"           foreground="mauve"/>
      <style name="def:operator"            foreground="sky"/>
      <style name="def:identifier"          foreground="lavender"/>
      <style name="def:function"            foreground="blue"/>
      <style name="def:type"                foreground="blue"/>
      <style name="def:preprocessor"        foreground="pink"/>
      <style name="def:error"               foreground="red"      underline="true"/>
      <style name="def:warning"             foreground="yellow"/>
      <style name="def:note"                foreground="teal"/>
      <style name="def:number"              foreground="peach"/>
      <style name="def:boolean"             foreground="peach"/>
      <style name="def:variable"            foreground="text"/>
      <style name="def:builtin"             foreground="red"/>
      <style name="def:net-address"         foreground="sky"      underline="true"/>
      <style name="def:heading"             foreground="blue"     bold="true"/>
      <style name="def:list-marker"         foreground="mauve"/>
    </style-scheme>
  '';

  dconf.settings."org/gnome/gedit/preferences/editor"."style-scheme-for-dark-theme-variant" =
    "catppuccin-${flavor}";
  dconf.settings."org/gnome/gedit/preferences/editor"."style-scheme-for-light-theme-variant" =
    "catppuccin-${flavor}";

  # ── Misc ──────────────────────────────────────────────────────────────────

  home.file."Pictures/Screenshots/.keep".text = "";
  home.file."Pictures/wallpapers/.keep".text = "";

  # VS Code can write its own fields into argv.json; use activation (not home.file)
  # so it doesn't get clobbered on each switch.
  home.activation.vscodeArgv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _argv="$HOME/.vscode/argv.json"
    mkdir -p "$(dirname "$_argv")"
    if [ -L "$_argv" ] || [ ! -f "$_argv" ]; then
      rm -f "$_argv"
      printf '{\n  "password-store": "gnome-libsecret"\n}\n' > "$_argv"
    fi
  '';
}
