return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Mason's prebuilt .NET binary can't find libicu on NixOS; use the nixpkgs one
      marksman = { mason = false },
    },
  },
}
