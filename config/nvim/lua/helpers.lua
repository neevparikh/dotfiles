-- vim:foldmethod=marker:foldlevel=0
require("io")
require("os")

-- {{{ macros -- uses vim version bc the lua version doesn't work
vim.cmd([[

function! CleanNoNameEmptyBuffers()
  let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && '.
        \ 'empty(bufname(v:val)) && bufwinnr(v:val) < 0 && ' .
        \ '(getbufline(v:val, 1, "$") == [""])')
  if !empty(buffers)
    exe 'bd! '.join(buffers, ' ')
  endif
endfunction

let s:atcount = 10
function! AtRepeat(_)
    " If no count is supplied use the one saved in s:atcount.
    " Otherwise save the new count in s:atcount, so it will be
    " applied to repeats.
    let s:atcount = v:count ? v:count : s:atcount
    " feedkeys() rather than :normal allows finishing in Insert
    " mode, should the macro do that. @@ is remapped, so 'opfunc'
    " will be correct, even if the macro changes it.
    call feedkeys(s:atcount.'@@')
endfunction

function! AtSetRepeat(_)
    set opfunc=AtRepeat
endfunction

" Called by g@ being invoked directly for the first time. Sets
" 'opfunc' ready for repeats with . by calling AtSetRepeat().
function! AtInit()
    " Make sure setting 'opfunc' happens here, after initial playback
    " of the macro recording, in case 'opfunc' is set there.
    set opfunc=AtSetRepeat
    return 'g@l'
endfunction

" Enable calling a function within the mapping for @
nnoremap <expr> <plug>@init AtInit()
" A macro could, albeit unusually, end in Insert mode.
inoremap <expr> <plug>@init "\<c-o>".AtInit()
xnoremap <expr> <plug>@init AtInit()

function! AtReg()
    let s:atcount = v:count1
    let c = nr2char(getchar())
    return '@'.c."\<plug>@init"
endfunction

nmap <expr> @ AtReg()

function! QRepeat(_)
    call feedkeys('@'.s:qreg)
endfunction

function! QSetRepeat(_)
    set opfunc=QRepeat
endfunction

function! QStop()
    set opfunc=QSetRepeat
    return 'g@l'
endfunction

nnoremap <expr> <plug>qstop QStop()
inoremap <expr> <plug>qstop "\<c-o>".QStop()

let s:qrec = 0
function! QStart()
    if s:qrec == 1
        let s:qrec = 0
        return "q\<plug>qstop"
    endif
    let s:qreg = nr2char(getchar())
    if s:qreg =~# '[0-9a-zA-Z"]'
        let s:qrec = 1
    endif
    return 'q'.s:qreg
endfunction

nmap <expr> q QStart()
]])

-- local at_count
-- local qreg
-- local qrec = 0
--
-- function AtRepeat(_)
--   -- If no count is supplied use the one saved in atcount.
--   -- Otherwise save the new count in s:atcount, so it will be
--   -- applied to repeats.
--
--   print("atrepeat")
--   print(vim.v.count)
--   if vim.v.count ~= 0 then
--     at_count = vim.v.count
--   end
--   print(vim.v.count1)
--
--   -- feedkeys() rather than :normal allows finishing in Insert
--   -- mode, should the macro do that. @@ is remapped, so 'opfunc'
--   -- will be correct, even if the macro changes it.
--   vim.fn.feedkeys(at_count .. '@@')
-- end
--
-- function AtSetRepeat(_)
--   print("atsetrepeat 100")
--   vim.opt.opfunc = 'v:lua.AtRepeat()'
--   print('opfunc at set')
--   print(vim.opt.opfunc)
-- end
--
-- -- Called by g@ being invoked directly for the first time. Sets
-- -- 'opfunc' ready for repeats with . by calling AtSetRepeat().
-- function AtInit()
--   -- Make sure setting 'opfunc' happens here, after initial playback
--   -- of the macro recording, in case 'opfunc' is set there.
--   print("atinit 111")
--   vim.opt.opfunc = 'v:lua.AtSetRepeat()'
--   print("opfunc")
--   print(vim.inspect(vim.opt.opfunc))
--   return 'g@l'
-- end
--
-- function AtReg()
--   at_count = vim.v.count1
--   print("atreg 120")
--   local c = vim.fn.nr2char(vim.fn.getchar())
--   print('@' .. c .. "\\<Plug>@init")
--   return '@' .. c .. "\\<Plug>@init"
-- end
--
-- function QRepeat(_)
--   print("qrep 127")
--   print("@" .. qreg)
--   vim.fn.feedkeys('@' .. qreg)
-- end
--
-- function QSetRepeat(_)
--   print("qsetrep 133")
--   vim.opt.opfunc = 'v:lua.QRepeat()'
-- end
--
-- function QStop()
--   print("qstop 138")
--   vim.opt.opfunc = 'v:lua.QSetRepeat()'
--   return 'g@l'
-- end
--
-- function QStart()
--   print("qstart 144")
--   if qrec == 1 then
--     qrec = 0
--     print("qstart: 'q\\<Plug>qstop'")
--     return 'q\\<Plug>qstop'
--   end
--   qreg = vim.fn.nr2char(vim.fn.getchar())
--   local r = vim.regex('[0-9a-zA-Z"]')
--   print(r)
--   if r:match_str(qreg) then
--     qrec = 1
--   end
--   print("qstart: q" .. qreg)
--   return 'q' .. qreg
-- end
--
-- function ExecuteMacroOverVisualRange()
--   vim.api.nvim_echo('@' .. vim.fn.getcmdline())
--   vim.api.nvim_command(":'<,'>normal!  @" .. vim.fn.nr2char(vim.fn.getchar()))
-- end

-- }}}

function HasWordsBefore()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

function ReadFile(path)
  local f, err = io.open(path, "r")
  if f == nil then
    print("err", err)
    return nil
  else
    local content = f:read("*all")
    f:close()
    return content
  end
end

function CheckBackSpace()
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
    return true
  else
    return false
  end
end

function SortAndReset()
  local curr_pos = vim.fn.getpos(".")
  vim.fn.setpos(".", vim.fn.getpos("$"))
  vim.api.nvim_command(vim.fn.search("+--", "b") + 1 .. ",$ sort")
  vim.fn.setpos(".", curr_pos)
end

function OpenWithName(name)
  vim.fn.termopen(vim.opt.shell:get())
  vim.api.nvim_command("keepalt file " .. vim.fn.expand("%:p") .. "//" .. name)
end

vim.api.nvim_create_user_command("OpenWithName", function(opts)
  local name = opts.args
  OpenWithName(name)
end, { nargs = 1 })

function MapWinCmd(key, command, ...)
  local suffix
  if select("#", ...) == 1 and select(1, ...) then
    suffix = ""
  else
    suffix = "<cr>"
  end

  local bind = vim.keymap.set
  bind("n", "<space>h" .. key, ":<c-u>aboveleft vnew <bar>" .. command .. suffix)
  bind("n", "<space>j" .. key, ":<c-u>belowright new <bar>" .. command .. suffix)
  bind("n", "<space>k" .. key, ":<c-u>aboveleft new <bar>" .. command .. suffix)
  bind("n", "<space>l" .. key, ":<c-u>belowright vnew <bar>" .. command .. suffix)
  bind("n", "<space>," .. key, ":<c-u>tabnew <bar>" .. command .. suffix)
  bind("n", "<space>." .. key, ":<c-u>" .. command .. suffix)
  bind("n", "<space>H" .. key, ":<c-u>topleft vnew <bar>" .. command .. suffix)
  bind("n", "<space>J" .. key, ":<c-u>botright new <bar>" .. command .. suffix)
  bind("n", "<space>K" .. key, ":<c-u>topleft new <bar>" .. command .. suffix)
  bind("n", "<space>L" .. key, ":<c-u>botright vnew <bar>" .. command .. suffix)
end

function HasExe(name)
  return function()
    return vim.fn.executable(name) == 1
  end
end

function ShouldSplitHorizontal()
  local height = vim.api.nvim_win_get_height(0)
  local width = vim.api.nvim_win_get_width(0)
  return height * 2.14 > width
end

function WindowSizeAwareSplit()
  if ShouldSplitHorizontal() then
    vim.cmd("split")
  else
    vim.cmd("vsplit")
  end
end

function SwitchTheme()
  local cur = vim.opt.background:get()
  if cur == "dark" then
    require("gruvbox").setup({ contrast = "soft" })
    vim.opt.background = "light"
    vim.fn.system("toggle-theme --light")
  else
    require("gruvbox").setup({ contrast = "hard" })
    vim.opt.background = "dark"
    vim.fn.system("toggle-theme --dark")
  end
end

function CheckTheme()
  local theme = ReadFile(os.getenv("HOME") .. "/.config/theme.yaml")
  if theme == nil then
    return "dark"
  else
    return theme:gsub("\n", "")
  end
end

function RegisterFzfCommand(cmd_prefix, name, cmd_suffix)
  local prefix = vim.g.fzf_vim["command_prefix"]
  if prefix == nil then
    prefix = ""
  end
  vim.cmd(cmd_prefix .. prefix .. name .. cmd_suffix)
end
