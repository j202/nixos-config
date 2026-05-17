# vim: set ft=nix ts=2 sw=2 sts=2 et:
# qutebrowser configuration with Proton Pass credential filling.
#
# First-time setup: run `pass-cli login` to authenticate the CLI.
# Keybind: ,p  → fill username + password for the current page.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  palette = builtins.fromJSON (
    builtins.readFile (config.catppuccin.sources.palette + "/palette.json")
  );
  flavor = config.catppuccin.flavor;
  c = builtins.mapAttrs (_: v: v.hex) palette.${flavor}.colors;
in
{
  programs.qutebrowser = {
    enable = true;

    settings = {
      colors = {
        completion = {
          fg = c.text;
          odd.bg = c.surface0;
          even.bg = c.base;
          category.bg = c.mantle;
          category.fg = c.mauve;
          item.selected.bg = c.surface1;
          item.selected.fg = c.text;
          item.selected.match.fg = c.mauve;
          match.fg = c.mauve;
          scrollbar.fg = c.surface2;
          scrollbar.bg = c.base;
        };
        statusbar = {
          normal.bg = c.base;
          normal.fg = c.text;
          insert.bg = c.green;
          insert.fg = c.base;
          passthrough.bg = c.blue;
          passthrough.fg = c.base;
          command.bg = c.mantle;
          command.fg = c.text;
          command.private.bg = c.mantle;
          command.private.fg = c.mauve;
          private.bg = c.surface0;
          private.fg = c.mauve;
          caret.bg = c.base;
          caret.fg = c.mauve;
          caret.selection.bg = c.base;
          caret.selection.fg = c.lavender;
          url.fg = c.text;
          url.hover.fg = c.blue;
          url.success.http.fg = c.green;
          url.success.https.fg = c.green;
          url.error.fg = c.red;
          url.warn.fg = c.yellow;
          progress.bg = c.mauve;
        };
        tabs = {
          bar.bg = c.mantle;
          odd.bg = c.mantle;
          odd.fg = c.subtext0;
          even.bg = c.mantle;
          even.fg = c.subtext0;
          selected.odd.bg = c.mauve;
          selected.odd.fg = c.base;
          selected.even.bg = c.mauve;
          selected.even.fg = c.base;
          pinned.odd.bg = c.surface0;
          pinned.odd.fg = c.subtext1;
          pinned.even.bg = c.surface0;
          pinned.even.fg = c.subtext1;
          pinned.selected.odd.bg = c.mauve;
          pinned.selected.odd.fg = c.base;
          pinned.selected.even.bg = c.mauve;
          pinned.selected.even.fg = c.base;
          indicator.start = c.mauve;
          indicator.stop = c.green;
          indicator.error = c.red;
        };
        hints = {
          bg = c.yellow;
          fg = c.base;
          match.fg = c.peach;
        };
        messages = {
          error.bg = c.red;
          error.fg = c.base;
          error.border = c.red;
          warning.bg = c.yellow;
          warning.fg = c.base;
          warning.border = c.yellow;
          info.bg = c.surface0;
          info.fg = c.text;
          info.border = c.surface0;
        };
        prompts = {
          bg = c.surface0;
          fg = c.text;
          border = c.mauve;
          selected.bg = c.surface1;
          selected.fg = c.text;
        };
        webpage = {
          darkmode.enabled = true;
          preferred_color_scheme = "dark";
          darkmode.policy.page = "smart";
          darkmode.policy.images = "smart";
        };
      };

      fonts = {
        default_family = "JetBrainsMono Nerd Font";
        default_size = "12pt";
        hints = "bold 12pt JetBrainsMono Nerd Font";
      };

      tabs = {
        last_close = "close";
        show = "multiple";
        title.format = "{audio}{current_title}";
      };

      hints = {
        chars = "asdfjkl;";
        auto_follow = "unique-match";
        uppercase = false;
      };

      auto_save.session = true;
      content.blocking.enabled = true;
      content.blocking.method = "both";

      url = {
        default_page = "https://home.alex-sh.co.uk";
        start_pages = [ "https://home.alex-sh.co.uk" ];
      };

      downloads.location.directory = "~/Downloads";

      statusbar.show = "always";
      scrolling.smooth = true;
    };

    # url.searchengines is a dict-type setting; home-manager splits nested
    # attrsets into dotted keys (url.searchengines.DEFAULT etc.) which
    # qutebrowser does not recognise — set it as a Python literal instead.
    extraConfig = ''
      c.url.searchengines = {
          "DEFAULT": "https://duckduckgo.com/?q={}",
          "gh":      "https://github.com/search?q={}",
          "yt":      "https://youtube.com/results?search_query={}",
          "nix":     "https://search.nixos.org/packages?query={}",
          "g":       "https://www.google.com/search?q={}",
          "brave":   "https://search.brave.com/search?q={}",
      }
    '';

    keyBindings = {
      normal = {
        ",p" = "spawn --userscript qute-proton-pass";
        ",pu" = "spawn --userscript qute-proton-pass copy-username";
        ",pp" = "spawn --userscript qute-proton-pass copy-password";
        ",pt" = "spawn --userscript qute-proton-pass copy-totp";
        ",b" = "spawn brave {url}";
      };
    };
  };

  # Place the userscript where qutebrowser looks for userscripts
  xdg.dataFile."qutebrowser/userscripts/qute-proton-pass" = {
    executable = true;
    source = ./qute-proton-pass.py;
  };
}
