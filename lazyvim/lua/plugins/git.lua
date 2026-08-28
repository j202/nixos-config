local function close_diffthis()
  local cur_tab = vim.api.nvim_get_current_tabpage()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(cur_tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf):match("^gitsigns://") then
      vim.api.nvim_win_close(win, true)
    end
  end
end

-- codediff's working-tree pane briefly shows a placeholder buffer (e.g.
-- "CodeDiff 2.2") before being swapped for your real file, once codediff
-- finishes fetching the git revision content for the other pane (an async
-- subprocess call internal to the plugin -- codediff/core/git.lua). Neither
-- public event (CodeDiffOpen, CodeDiffFileSelect) fires after that swap, so
-- there's nothing to hook cleanly. Poll for the swap instead: check every
-- 50ms, apply the saved cursor and stop as soon as the real buffer shows up,
-- give up after 3s so a pathological case can't leave a timer running
-- forever.
local codediff_restore

-- Returns true once applied (or if there was nothing to do).
local function restore_codediff_cursor()
  if not codediff_restore then
    return true
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf) == codediff_restore.path then
      pcall(vim.api.nvim_win_set_cursor, win, { codediff_restore.line, codediff_restore.col })
      codediff_restore = nil
      return true
    end
  end
  return false
end

local function open_codediff()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    codediff_restore = nil
    vim.cmd("CodeDiff")
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  codediff_restore = { path = bufname, line = cursor[1], col = cursor[2] }
  vim.cmd("CodeDiff")

  local interval, timeout, elapsed = 50, 3000, 0
  local timer = vim.uv.new_timer()
  timer:start(
    interval,
    interval,
    vim.schedule_wrap(function()
      elapsed = elapsed + interval
      if restore_codediff_cursor() or elapsed >= timeout then
        timer:stop()
        timer:close()
      end
    end)
  )
end

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
      },
      -- Copy of LazyVim's default on_attach (lazyvim.plugins.editor), with
      -- <leader>ghd/<leader>ghD turned into a toggle that cleanly closes the
      -- diff split instead of leaving the readonly gitsigns:// buffer around.
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", function()
          if vim.wo.diff then close_diffthis() else gs.diffthis() end
        end, "Diff This")
        map("n", "<leader>ghD", function()
          if vim.wo.diff then close_diffthis() else gs.diffthis("~") end
        end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    opts = {
      diff = {
        layout = "side-by-side",
        -- Default true: jumps to the first hunk on open, discarding
        -- wherever your cursor actually was in the file.
        jump_to_first_change = false,
      },
    },
    keys = {
      -- VS Code-style diff (character-level highlighting via VS Code's own
      -- diff algorithm), with a runtime `t` toggle between side-by-side and
      -- inline/unified -- unlike gitsigns, which is stuck on Neovim's
      -- native split-based diff engine and can't do unified.
      -- Bare `:CodeDiff` opens its explorer sidebar *and* auto-selects the
      -- diff for the file you invoked it from (confirmed: not just
      -- alphabetically-first) -- one binding for both. ]f/[f cycle files;
      -- g? shows the full keymap cheatsheet from inside any codediff view.
      { "<leader>gc", open_codediff, desc = "CodeDiff (current file + explorer)" },
    },
  },
}
