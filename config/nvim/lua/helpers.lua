-- vim:foldmethod=marker:foldlevel=0
require("io")
require("os")

vim.cmd([[

function! CleanNoNameEmptyBuffers()
  let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && '.
        \ 'empty(bufname(v:val)) && !(bufname(v:val) =~ "^health:\//\//.*$") && bufwinnr(v:val) < 0 && ' .
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

function CheckSpaceBehind()
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
  bind("n", "<leader>h" .. key, ":<c-u>aboveleft vnew <bar>" .. command .. suffix)
  bind("n", "<leader>j" .. key, ":<c-u>belowright new <bar>" .. command .. suffix)
  bind("n", "<leader>k" .. key, ":<c-u>aboveleft new <bar>" .. command .. suffix)
  bind("n", "<leader>l" .. key, ":<c-u>belowright vnew <bar>" .. command .. suffix)
  bind("n", "<leader>," .. key, ":<c-u>tabnew <bar>" .. command .. suffix)
  bind("n", "<leader>." .. key, ":<c-u>" .. command .. suffix)
  bind("n", "<leader>H" .. key, ":<c-u>topleft vnew <bar>" .. command .. suffix)
  bind("n", "<leader>J" .. key, ":<c-u>botright new <bar>" .. command .. suffix)
  bind("n", "<leader>K" .. key, ":<c-u>topleft new <bar>" .. command .. suffix)
  bind("n", "<leader>L" .. key, ":<c-u>botright vnew <bar>" .. command .. suffix)
end

function HasExe(name)
  return function()
    return vim.fn.executable(name) == 1
  end
end

vim.api.nvim_create_user_command("Scratch", function()
  local random_string = ""
  for _ = 1, 5 do
    random_string = random_string .. string.char(math.random(97, 97 + 25))
  end
  vim.cmd(
    "enew | setlocal bufhidden=hide nobuflisted buftype=nowrite noswapfile | file [scratch-"
      .. random_string
      .. "]"
  )
end, { nargs = 0 })

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
    vim.fn.jobstart("toggle-theme --light")
    SwitchThemeWithoutToggling("light")
  else
    vim.fn.jobstart("toggle-theme --dark")
    SwitchThemeWithoutToggling("dark")
  end
end

function SwitchThemeWithoutToggling(to_switch)
  if to_switch == "light" then
    require("gruvbox").setup({ contrast = GetContrast("light") })
    vim.opt.background = "light"
  elseif to_switch == "dark" then
    require("gruvbox").setup({ contrast = GetContrast("dark") })
    vim.opt.background = "dark"
  else
    error("Unknown current variant: " .. to_switch)
  end
end

function GetContrast(variant)
  if variant == "dark" then
    return "hard"
  elseif variant == "light" then
    return ""
  else
    error("Unknown variant: " .. variant)
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

function PrintPath()
  vim.print(vim.fn.expand("%:p"))
end
