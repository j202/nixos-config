-- VSG only where the project has configured it, and only if the project's dev shell has put
-- vsg on PATH: never with VSG's defaults, never with a global config.
local function find_vsg_config(filename)
  return vim.fs.find({ "vsg.yaml" }, { path = filename, upward = true })[1]
end

local function in_vsg_project(ctx)
  return vim.fn.executable("vsg") == 1 and find_vsg_config(ctx.filename) ~= nil
end

return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- nvim-lint's vsg linter is a function, and LazyVim replaces (not merges) a function linter
      -- with a table from opts.linters, so build the table from the linter's own definition.
      local vsg = require("lint.linters.vsg")()
      vsg.condition = in_vsg_project
      -- The built-in args pick whichever of a dozen config names is nearest, or a global one.
      vsg.args = {
        "-of",
        "syntastic",
        "--stdin",
        -- Without it VSG stops reporting after the first phase that has violations.
        "--all_phases",
        "-c",
        function()
          return find_vsg_config(vim.api.nvim_buf_get_name(0))
        end,
      }
      opts.linters = vim.tbl_extend("force", opts.linters or {}, { vsg = vsg })
      opts.linters_by_ft = vim.tbl_extend("force", opts.linters_by_ft or {}, { vhdl = { "vsg" } })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { vhdl = { "vsg" } },
      formatters = {
        vsg = {
          -- vsg --fix exits 1 when violations remain that it cannot fix, even after rewriting
          -- the file; conform discards the result unless 1 is accepted.
          exit_codes = { 0, 1 },
          condition = function(_, ctx)
            return in_vsg_project(ctx)
          end,
        },
      },
    },
  },
}
