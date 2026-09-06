return {
  "j202/vhdl-pretty.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = { "vhdl" },
  config = function()
    require("vhdl_pretty").setup()
  end,
}
