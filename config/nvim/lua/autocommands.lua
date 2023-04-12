-- vim: set foldmethod=marker:
require("helpers")

local autocmd = vim.api.nvim_create_autocmd
local function create_augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

local cpp = create_augroup('cpp')
local formatting = create_augroup('formatting')

-- {{{ general
autocmd({ "BufLeave" }, { pattern = "*", callback = CleanNoNameEmptyBuffers })
autocmd({ "BufWrite" }, { pattern = "*.todo", callback = SortAndReset })
autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, { pattern = "*", command = "set relativenumber" })
autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, { pattern = "*", command = "set norelativenumber number" })
autocmd({ "TermOpen" }, { pattern = "*", command = "setlocal listchars= nonumber norelativenumber" })
-- }}}


-- {{{ filetype
autocmd({ "FileType" }, {
  pattern = { "markdown", "text", "rst" },
  command = "setlocal spell textwidth=100"
})
autocmd({ "FileType" }, {
  pattern = { "todo" },
  command = "setlocal wrap linebreak textwidth=100"
})
autocmd({ "FileType" }, { group = cpp, pattern = "cpp", command = "setlocal commentstring=//\\ %s" })
-- }}}


-- {{{ formatting
autocmd({ "BufWritePre", "FileWritePre" }, {
  group = formatting, pattern = { "*.cpp", "*.rs", "*.lua", "*.go", "*.h" },
  callback = function() vim.lsp.buf.format() end
})
-- }}}
