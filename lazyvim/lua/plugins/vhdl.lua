-- VSG only where the project has configured it, and only if vsg is on PATH: never with VSG's
-- defaults, never with a global config.
local function find_vsg_config(filename)
  return vim.fs.find({ "vsg.yaml" }, { path = filename, upward = true })[1]
end

local function in_vsg_project(ctx)
  return vim.fn.executable("vsg") == 1 and find_vsg_config(ctx.filename) ~= nil
end

-- vhdl_ls keeps files it already had open in the libraries they were in before vhdl_ls.toml changed,
-- so it goes on reporting duplicate entities; a restart does not. Restart it when the file is rewritten.
local watchers = {}

local function watch_config(client)
  local watcher = assert(vim.uv.new_fs_event())
  local debounce = assert(vim.uv.new_timer())
  watcher:start(client.root_dir or vim.uv.cwd(), {}, function(err, filename)
    if err or filename ~= "vhdl_ls.toml" then
      return
    end
    debounce:stop()
    debounce:start(
      500,
      0,
      vim.schedule_wrap(function()
        vim.cmd("lsp restart vhdl_ls")
        vim.notify("vhdl_ls.toml changed: restarted vhdl_ls")
      end)
    )
  end)
  watchers[client.id] = { watcher, debounce }
end

local function unwatch_config(_, _, client_id)
  for _, handle in ipairs(watchers[client_id] or {}) do
    handle:close()
  end
  watchers[client_id] = nil
end

return {
  {
    "neovim/nvim-lspconfig",
    -- Only hooks vhdl_ls if something else starts it; this does not add it to the servers Mason installs.
    init = function()
      vim.lsp.config("vhdl_ls", { on_init = watch_config, on_exit = unwatch_config })
    end,
  },
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
