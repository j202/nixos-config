# vim: set ft=nix ts=2 sw=2 sts=2 et:
# qutebrowser configuration with Proton Pass credential filling.
#
# First-time setup: run `pass-cli login` to authenticate the CLI.
# Keybind: ,p  → fill username + password for the current page.
{
  config,
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
          category = {
            bg = c.mantle;
            fg = c.mauve;
          };
          item.selected = {
            bg = c.surface1;
            fg = c.text;
            match.fg = c.mauve;
          };
          match.fg = c.mauve;
          scrollbar = {
            fg = c.surface2;
            bg = c.base;
          };
        };
        statusbar = {
          normal = {
            bg = c.base;
            fg = c.text;
          };
          insert = {
            bg = c.green;
            fg = c.base;
          };
          passthrough = {
            bg = c.blue;
            fg = c.base;
          };
          command = {
            bg = c.mantle;
            fg = c.text;
            private = {
              bg = c.mantle;
              fg = c.mauve;
            };
          };
          private = {
            bg = c.surface0;
            fg = c.mauve;
          };
          caret = {
            bg = c.base;
            fg = c.mauve;
            selection = {
              bg = c.base;
              fg = c.lavender;
            };
          };
          url = {
            fg = c.text;
            hover.fg = c.blue;
            success = {
              http.fg = c.green;
              https.fg = c.green;
            };
            error.fg = c.red;
            warn.fg = c.yellow;
          };
          progress.bg = c.mauve;
        };
        tabs = {
          bar.bg = c.mantle;
          odd = {
            bg = c.mantle;
            fg = c.subtext0;
          };
          even = {
            bg = c.mantle;
            fg = c.subtext0;
          };
          selected = {
            odd = {
              bg = c.mauve;
              fg = c.base;
            };
            even = {
              bg = c.mauve;
              fg = c.base;
            };
          };
          pinned = {
            odd = {
              bg = c.surface0;
              fg = c.subtext1;
            };
            even = {
              bg = c.surface0;
              fg = c.subtext1;
            };
            selected = {
              odd = {
                bg = c.mauve;
                fg = c.base;
              };
              even = {
                bg = c.mauve;
                fg = c.base;
              };
            };
          };
          indicator = {
            start = c.mauve;
            stop = c.green;
            error = c.red;
          };
        };
        hints = {
          bg = c.yellow;
          fg = c.base;
          match.fg = c.peach;
        };
        messages = {
          error = {
            bg = c.red;
            fg = c.base;
            border = c.red;
          };
          warning = {
            bg = c.yellow;
            fg = c.base;
            border = c.yellow;
          };
          info = {
            bg = c.surface0;
            fg = c.text;
            border = c.surface0;
          };
        };
        prompts = {
          bg = c.surface0;
          fg = c.text;
          border = c.mauve;
          selected = {
            bg = c.surface1;
            fg = c.text;
          };
        };
        webpage = {
          preferred_color_scheme = "dark";
          darkmode = {
            enabled = true;
            policy = {
              page = "smart";
              images = "smart";
            };
          };
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
