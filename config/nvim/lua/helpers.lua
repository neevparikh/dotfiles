-- vim: set foldmethod=marker:
require('io')
require('os')

local at_count
local qreg
local qrec = 0

-- {{{ macros
function AtRepeat(_)
  -- If no count is supplied use the one saved in atcount.
  -- Otherwise save the new count in s:atcount, so it will be
  -- applied to repeats.

  if vim.v.count then
    at_count = vim.v.count
  end

  -- feedkeys() rather than :normal allows finishing in Insert
  -- mode, should the macro do that. @@ is remapped, so 'opfunc'
  -- will be correct, even if the macro changes it.
  vim.call(vim.fn.feedkeys(at_count .. '@@'))
end

function AtSetRepeat(_)
  vim.opt.opfunc = AtRepeat
end

-- " Called by g@ being invoked directly for the first time. Sets
-- " 'opfunc' ready for repeats with . by calling AtSetRepeat().
function AtInit()
  -- Make sure setting 'opfunc' happens here, after initial playback
  -- of the macro recording, in case 'opfunc' is set there.
  vim.opt.opfunc = AtSetRepeat
  return 'g@l'
end

function AtReg()
  at_count = vim.v.count1
  local c = vim.fn.nr2char(vim.fn.getchar())
  return '@' .. c .. "\\<plug>@init"
end

function QRepeat(_)
  vim.call(vim.fn.feedkeys('@' .. qreg))
end

function QSetRepeat(_)
  vim.opt.opfunc = QRepeat
end

function QStop()
  vim.opt.opfunc = QSetRepeat
  return 'g@l'
end

function QStart()
  if qrec == 1 then
    qrec = 0
    return 'q\\<plug>qstop'
  end
  qreg = vim.fn.nr2char(vim.fn.getchar())
  local r = vim.regex('[0-9a-zA-Z"]')
  if r:match_str(qreg) then
    qrec = 1
  end
  return 'q' .. qreg
end

function ExecuteMacroOverVisualRange()
  vim.api.nvim_echo('@' .. vim.fn.getcmdline())
  vim.api.nvim_command(":'<,'>normal!  @" .. vim.fn.nr2char(vim.fn.getchar()))
end

-- }}}

-- {{{ other

function ReadFile(path)
  local f, err = io.open(path, 'r')
  if f == nil then
    print(err)
    return nil
  else
    local content = f:read('*all')
    f:close()
    return content
  end
end

function CheckBackSpace()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

function CleanNoNameEmptyBuffers()
  local buffers = vim.fn.filter(
    vim.fn.range(1, vim.fn.bufnr('$')),
    'buflisted(v:val) && '
    .. 'empty(bufname(v:val)) && bufwinnr(v:val) < 0 && '
    .. '(getbufline(v:val, 1, "$") == [""])'
  )

  if not vim.fn.empty(buffers) then
    vim.fn.exe('bd ' .. vim.fn.join(buffers, ' '))
  end
end

function SortAndReset()
  local curr_pos = vim.fn.getpos('.')
  vim.fn.setpos('.', vim.fn.getpos('$'))
  vim.api.nvim_command(vim.fn.search("+--", 'b') + 1 .. ",$ sort")
  vim.fn.setpos('.', curr_pos)
end

function OpenWithName(name)
  vim.fn.termopen(vim.opt.shell)
  vim.api.nvim_command('keepalt file ' .. vim.fn.expand('%:p') .. '//' .. name)
end

vim.api.nvim_create_user_command('OpenWithName', function(opts)
  local name = opts.args
  OpenWithName(name)
end, { nargs = 1 })

function MapWinCmd(key, command, ...)
  local suffix
  if select('#', ...) == 1 and select(1, ...) then
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

-- }}}
