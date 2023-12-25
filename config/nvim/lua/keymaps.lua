-- vim:foldmethod=marker:foldlevel=0
require("helpers")
local bind = vim.keymap.set

-- {{{
local function remap(to_remap)
  return { remap = to_remap }
end

-- }}}

-- {{{ miniyank
bind("n", "p", "<Plug>(miniyank-autoput)")
bind("n", "P", "<Plug>(miniyank-autoPut)")
bind("x", "p", "<Plug>(miniyank-autoput)")
bind("x", "P", "<Plug>(miniyank-autoPut)")
bind("n", "<C-n>", "<Plug>(miniyank-cycle)")
bind("n", "<C-N>", "<Plug>(miniyank-cycleback)")
-- }}}

-- {{{ window management
-- {{{ buffers
bind("n", "<C-h>", ":bnext<CR>")
bind("n", "<C-l>", ":bprev<CR>")
-- }}}

-- {{{ split pane navigation
bind("n", "<M-l>", "<C-w>l")
bind("n", "<M-h>", "<C-w>h")
bind("n", "<M-k>", "<C-w>k")
bind("n", "<M-j>", "<C-w>j")
-- }}}

-- {{{ terminal navigation
bind("t", "<M-l>", "<C-\\><C-n><C-w>l")
bind("t", "<M-h>", "<C-\\><C-n><C-w>h")
bind("t", "<M-k>", "<C-\\><C-n><C-w>k")
bind("t", "<M-j>", "<C-\\><C-n><C-w>j")
bind("t", "<M-space>", "<C-\\><C-n>")
-- }}}

-- {{{ resizing
bind("", "<up>", "<C-W>+")
bind("", "<down>", "<C-W>-")
bind("", "<left>", "3<C-W>>")
bind("", "<right>", "3<C-W><")
bind("n", "<M-=>", "<C-w>=")
bind("n", "<M-->", "<C-w>_")
bind("n", "<M-\\>", "<C-w><bar>")
bind("n", "<M-H>", "<C-w>H")
bind("n", "<M-J>", "<C-w>J")
bind("n", "<M-K>", "<C-w>K")
bind("n", "<M-L>", "<C-w>L")
-- }}}
-- }}}

-- {{{ general
bind("", "Y", "y$", remap(true))
bind("n", "U", "<C-r>")
bind("x", "p", "pgvy", remap(true))
bind("n", "zJ", "zczjzo")
bind("n", "zK", "zczkzo")
bind("n", "gV", "`[v`]")
bind("n", "<M-c>", SwitchTheme)
-- }}}

-- {{{ lsp
local lsp_opts = { noremap = true, silent = true }
bind("n", "K", vim.lsp.buf.hover, lsp_opts)
bind("x", "<space>f", vim.lsp.buf.format, lsp_opts)
bind("n", "<space>f", function()
  vim.lsp.buf.format({ async = true })
end, lsp_opts)
bind("n", "<space>d", vim.lsp.buf.definition, lsp_opts)
bind("n", "<space>D", vim.lsp.buf.declaration, lsp_opts)
bind("n", "<space>i", vim.lsp.buf.implementation, lsp_opts)
bind("n", "<space>t", vim.lsp.buf.type_definition, lsp_opts)
bind("n", "<space>u", vim.lsp.buf.references, lsp_opts)
bind("n", "<space>rn", vim.lsp.buf.rename, lsp_opts)
bind("x", "<space>c", vim.lsp.buf.code_action, lsp_opts)
bind("n", "<space>C", vim.lsp.buf.code_action, lsp_opts)
bind("n", "<space>K", vim.lsp.buf.signature_help, lsp_opts)
bind("n", "<space>N", vim.diagnostic.open_float, lsp_opts)
bind("n", "<space>p", vim.diagnostic.goto_prev, lsp_opts)
bind("n", "<space>n", vim.diagnostic.goto_next, lsp_opts)
-- }}}

-- {{{ completion
function GetCmpMappings()
  local cmp = require("cmp")
  local ls = require("luasnip")
  local select_opts = { behavior = cmp.SelectBehavior.Select }
  return {
    -- confirm selection
    ["<CR>"] = cmp.mapping.confirm({ select = false }),

    -- -- navigate items on the list
    -- ["J"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item(select_opts)
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),
    -- ["K"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item(select_opts)
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),

    -- scroll up and down in the completion documentation
    ["<c-j>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.mapping.scroll_docs(5)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<c-k>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.mapping.scroll_docs(-5)
      else
        fallback()
      end
    end, { "i", "s" }),

    -- toggle completion
    ["<C-f>"] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.close()
      else
        cmp.complete()
      end
    end),

    -- when menu is visible, navigate to next item
    -- when line is empty, insert a tab character
    -- else, activate completion
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item(select_opts)
      elseif ls.expand_or_jumpable() then
        ls.expand_or_jump()
      elseif CheckBackSpace() then
        fallback()
      else
        cmp.complete()
      end
    end, { "i", "s" }),

    -- when menu is visible, navigate to previous item on list
    -- else, revert to default behavior
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item(select_opts)
      elseif ls.jumpable(-1) then
        ls.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }
end

-- }}}

-- {{{ macros (doesn't work, see helpers macro section)
-- bind('x', '@', ':<c-u>ExecuteMacroOverVisualRange()', remap(false))
-- bind({ 'n', 'x' }, '<Plug>@init', "AtInit()", { expr = true })
-- bind('n', '<Plug>qstop', 'QStop()', { expr = true })
-- bind('n', '@', 'AtReg()', { expr = true })
-- bind('n', 'q', 'QStart()', { expr = true, remap = true })
-- bind('i', '<Plug>@init', '"\\<c-o>".AtInit()', { expr = true })
-- bind('i', '<Plug>qstop', '"\\<c-o>".QStop()', { expr = true })
-- }}}

-- {{{ plugin
-- {{{ vimdiff
bind("n", "<space>gd", ":Gvdiffsplit!<CR>")
-- }}}

-- {{{ luasnip
-- bind('i',
--   "<Tab>",
--   "luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'",
--   { silent = true, expr = true, remap = true }
-- )
-- bind('s', '<Tab>', "<cmd>lua require('luasnip').jump(1)<cr>",
--   { silent = true, remap = false }
-- )
-- bind({ 's', 'i' }, '<S-Tab>', "<cmd>lua require('luasnip').jump(-1)<cr>",
--   { silent = true, remap = false }
-- )
-- }}}
-- }}}

-- {{{ rewrite built in commands
vim.cmd("cabbrev split lua WindowSizeAwareSplit()")
vim.cmd("cabbrev h H")
-- }}}

-- {{{ commands
MapWinCmd("t", "terminal")
MapWinCmd("T", "OpenWithName ", true)
MapWinCmd("e", " e ", true)
MapWinCmd("w", "Scratch")
MapWinCmd("f", "FzfFiles")
MapWinCmd("F", "FzfFiles ", true)
MapWinCmd("b", "Buffers")
MapWinCmd("g", "Files")
MapWinCmd("G", "Files ", true)
MapWinCmd("r", "FzfRgWithArgs ", true)
MapWinCmd("R", "FzfRG")
MapWinCmd("c", "normal! \\<c-o>")
MapWinCmd("s", "Startify")
MapWinCmd("d", "e ~/.todo")

vim.api.nvim_create_user_command("FilesFZF", function(opts)
  local path = opts.args
  if path == "" then
    vim.cmd([[
    call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
    ]])
  else
    vim.cmd([[
    call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
    ]])
  end
end, { nargs = "?" })
-- }}}
