-- vim: set foldmethod=marker:
require('helpers')
local bind = vim.keymap.set

-- {{{
local function remap(to_remap)
  return { remap = to_remap }
end

-- }}}

-- {{{ window management
-- {{{ buffers
bind('n', '<C-h>', ':bnext<CR>')
bind('n', '<C-l>', ':bprev<CR>')
-- }}}

-- {{{ split pane navigation
bind('n', '<M-l>', '<C-w>l')
bind('n', '<M-h>', '<C-w>h')
bind('n', '<M-k>', '<C-w>k')
bind('n', '<M-j>', '<C-w>j')
-- }}}

-- {{{ terminal navigation
bind('t', '<M-l>', '<C-\\><C-n><C-w>l')
bind('t', '<M-h>', '<C-\\><C-n><C-w>h')
bind('t', '<M-k>', '<C-\\><C-n><C-w>k')
bind('t', '<M-j>', '<C-\\><C-n><C-w>j')
bind('t', '<M-space>', '<C-\\><C-n>')
-- }}}

-- {{{ resizing
bind('', '<up>', '<C-W>+')
bind('', '<down>', '<C-W>-')
bind('', '<left>', '3<C-W>>')
bind('', '<right>', '3<C-W><')
bind('n', '<M-=>', '<C-w>=')
bind('n', '<M-->', '<C-w>_')
bind('n', '<M-\\>', '<C-w><bar>')
bind('n', '<M-H>', '<C-w>H')
bind('n', '<M-J>', '<C-w>J')
bind('n', '<M-K>', '<C-w>K')
bind('n', '<M-L>', '<C-w>L')
-- }}}
-- }}}

-- {{{ general
bind('', 'Y', 'y$', remap(true))
bind('n', 'U', '<C-r>')
bind('x', 'p', 'pgvy', remap(true))
bind('n', 'zJ', 'zczjzo')
bind('n', 'zK', 'zczkzo')
bind('n', 'gV', '`[v`]')
bind('n', '<M-c>', SwitchTheme)
-- }}}

-- {{{ lsp
local lsp_opts = { noremap = true, silent = true }
bind('n', '<space>k', vim.lsp.buf.hover, lsp_opts)
bind('x', '<space>f', vim.lsp.buf.range_formatting, lsp_opts)
bind('n', '<space>f', vim.lsp.buf.formatting, lsp_opts)
bind('n', '<space>d', vim.lsp.buf.definition, lsp_opts)
bind('n', '<space>D', vim.lsp.buf.declaration, lsp_opts)
bind('n', '<space>i', vim.lsp.buf.implementation, lsp_opts)
bind('n', '<space>t', vim.lsp.buf.type_definition, lsp_opts)
bind('n', '<space>u', vim.lsp.buf.references, lsp_opts)
bind('n', '<space>rn', vim.lsp.buf.rename, lsp_opts)
bind('x', '<space>c', vim.lsp.buf.range_code_action, lsp_opts)
bind('n', '<space>C', vim.lsp.buf.code_action, lsp_opts)
bind('n', '<space>K', vim.lsp.buf.signature_help, lsp_opts)
bind('n', '<space>N', vim.diagnostic.open_float, lsp_opts)
bind('n', '<space>p', vim.diagnostic.goto_prev, lsp_opts)
bind('n', '<space>n', vim.diagnostic.goto_next, lsp_opts)
-- }}}

-- {{{ macros
bind('x', '@', ':<c-u>v:lua.ExecuteMacroOverVisualRange()<cr>', remap(false))
bind('n', '<expr>', '<plug>@init v:lua.AtInit()', remap(false))
bind('i', '<expr>', '<plug>@init "\\<c-o>".v:lua.AtInit()', remap(false))
bind('x', '<expr>', '<plug>@init v:lua.AtInit()', remap(false))
bind('n', '<expr>', '<plug>qstop v:lua.QStop()', remap(false))
bind('n', '<expr>', '@ v:lua.AtReg()', remap(true))
bind('i', '<expr>', '<plug>qstop "\\<c-o>".v:lua.QStop()', remap(false))
bind('n', '<expr>', 'q v:lua.QStart()', remap(true))
-- }}}

-- {{{ plugin
-- {{{ vimdiff
bind('n', '<space>gd', ':Gvdiffsplit!<CR>')
-- }}}

-- {{{ miniyank
bind('n', 'p', '<Plug>(miniyank-autoput)')
bind('n', 'P', '<Plug>(miniyank-autoPut)')
bind('x', 'p', '<Plug>(miniyank-autoput)')
bind('x', 'P', '<Plug>(miniyank-autoPut)')
bind('n', '<space>n', '<Plug>(miniyank-cycle)')
bind('n', '<space>N', '<Plug>(miniyank-cycleback)')
-- }}}

-- {{{ luasnip
bind('i',
  "<Tab>",
  "luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'",
  { silent = true, expr = true, remap = true }
)
bind('s', '<Tab>', "<cmd>lua require('luasnip').jump(1)<cr>",
  { silent = true, remap = false }
)
bind({ 's', 'i' }, '<S-Tab>', "<cmd>lua require('luasnip').jump(-1)<cr>",
  { silent = true, remap = false }
)
-- }}}

-- }}}

-- {{{ commands
MapWinCmd("t", "terminal")
MapWinCmd("T", "OpenWithName ", true)
MapWinCmd("e", " e ", true)
MapWinCmd("w", "enew <bar> setlocal bufhidden=hide nobuflisted buftype=nofile")
MapWinCmd("f", "Files")
MapWinCmd("F", "Files ", true)
MapWinCmd("b", "Buffers")
MapWinCmd("g", "GFiles")
MapWinCmd("G", "GFiles ", true)
MapWinCmd("r", "RgPreview ", true)
MapWinCmd("R", "RgPreviewHidden")
MapWinCmd(";r", "RgPreview ", true)
MapWinCmd(";R", "RgPreview")
MapWinCmd("c", "normal! \\<c-o>")
MapWinCmd("s", "Startify")
MapWinCmd("d", "e ~/.todo")
-- }}}
