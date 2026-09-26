return {
  -- Mason's bin directory goes last on PATH: the dev shell and the system win, Mason is the fallback.
  { "mason-org/mason.nvim", opts = { PATH = "append" } },
  {
    -- clang-format formats C and C++; the LspAttach in config/autocmds.lua keeps clangd's own formatter out.
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { c = { "clang_format" }, cpp = { "clang_format" } } },
  },
}
