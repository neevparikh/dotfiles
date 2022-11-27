set clipboard+=unnamedplus

" Plugins
filetype off
call plug#begin('~/.local/share/nvim/plugged')

Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'neevparikh/gruvbox' 
Plug 'lervag/vimtex'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'romainl/vim-cool' 
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim' 
Plug 'tmhedberg/SimpylFold'
Plug 'tommcdo/vim-lion' 
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-conflicted'
Plug '/lightline-gruvbox.vim'
Plug 'neevparikh/lightline-gruvbox.vim'
Plug 'simnalamburt/vim-mundo'
Plug 'unblevable/quick-scope'
Plug 'wellle/targets.vim'
Plug 'unblevable/quick-scope'
Plug 'bfredl/nvim-miniyank'
Plug 'machakann/vim-highlightedyank'
Plug 'airblade/vim-rooter'
Plug 'chrisbra/Colorizer'

call plug#end()
filetype indent plugin on

" Vimtex
let g:vimtex_fold_enabled = 1 
let g:vimtex_format_enabled = 1
let g:vimtex_quickfix_open_on_warning = 0

let g:rooter_manual_only = 1
let g:rooter_silent_chdir = 1

let g:coc_global_extensions = [
            \ 'coc-snippets', 
            \ 'coc-vimlsp',
            \ 'coc-dictionary',
            \ 'coc-word',
            \ 'coc-syntax',
            \ 'coc-git', 
            \ 'coc-pyright',
            \ 'coc-json',
            \ 'coc-vimtex']

" Autocomplete
" inoremap <expr> <Tab> pumvisible() ? \"\<C-n>" : \"\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? \"\<C-p>" : \"\<S-Tab>"
" inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : \"\<C-g>u\<CR>"

inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

nmap p <Plug>(miniyank-autoput)
nmap P <Plug>(miniyank-autoPut)
xmap p <Plug>(miniyank-autoput)
xmap P <Plug>(miniyank-autoPut)

nmap <space>n <Plug>(miniyank-cycle)
nmap <space>N <Plug>(miniyank-cycleback)

" Vim-Fugitive
nnoremap <space>gd :Gvdiffsplit!<CR>

" Remapping
map Y y$
nnoremap U <C-r>
nmap <space>s <cmd>source %<cr> 
tnoremap <M-space> <C-\><C-n>
nnoremap <M-c> :call SwitchColorScheme()<CR>

noremap <up>    <C-W>+
noremap <down>  <C-W>-
noremap <left>  3<C-W>>
noremap <right> 3<C-W><
xnoremap p pgvy
nnoremap zJ zczjzo
nnoremap zK zczkzo
nnoremap gV `[v`]
nnoremap <M-=> <C-w>=
nnoremap <M--> <C-w>_
nnoremap <M-\> <C-w><bar>
nnoremap <M-H> <C-w>H
nnoremap <M-J> <C-w>J
nnoremap <M-K> <C-w>K
nnoremap <M-L> <C-w>L


nmap <M-n> <Plug>(coc-diagnostic-next)
nmap <M-p> <Plug>(coc-diagnostic-prev)
nmap <space>f <Plug>(coc-format-selected)
nmap <space>F <Plug>(coc-format)
nmap <space>A <Plug>(coc-format-all)
nmap <space>D <Plug>(coc-declaration)
nmap <space>d <Plug>(coc-definition)
nmap <space>d <Plug>(coc-definition)
nmap <space>i <Plug>(coc-implementation)
nmap <space>u <Plug>(coc-references)
nmap <space>re <Plug>(coc-refactor)
nmap <space>rn <Plug>(coc-rename)
nmap <space>c <Plug>(coc-fix-current)
xnoremap <space>x <Plug>(coc-convert-snippet)
vmap <space>j <Plug>(coc-snippets-select)

nnoremap <silent> <space>K <Cmd>call CocAction('doHover')<CR>
xnoremap <silent> <space>K <Cmd>call CocAction('doHover')<CR>
nnoremap <silent> <K> :call doHover()<CR>
xnoremap <silent> <K> :call doHover()<CR>

xnoremap @ :<c-u>call ExecuteMacroOverVisualRange()<cr>

function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal!  @".nr2char(getchar())
endfunction

" When . repeats g@, repeat the last macro.
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

function! CleanNoNameEmptyBuffers()
  let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && '.
        \ 'empty(bufname(v:val)) && bufwinnr(v:val) < 0 && ' .
        \ '(getbufline(v:val, 1, "$") == [""])')
  if !empty(buffers)
    exe 'bd '.join(buffers, ' ')
  endif
endfunction

augroup CleanBuffers
  autocmd!
  autocmd BufLeave * call CleanNoNameEmptyBuffers()
augroup END

augroup SortTodo
    autocmd!
    autocmd BufWrite *.todo call SortAndReset()
augroup END

function SortAndReset()
    let curr_pos = getpos('.')
    call setpos('.', getpos('$'))
    execute search("+--", 'b') + 1 . ",$ sort"
    call setpos('.', curr_pos)
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

inoremap <c-f> <c-g>u<Esc>[s1z=`]a<c-g>u

function! FixSpellingMistake() abort
  let orig_spell_pos = getcurpos()
  normal! [s1z=
  call setpos('.', orig_spell_pos)
endfunction

nnoremap <c-f> <Cmd>call FixSpellingMistake()<cr>

function! SetColors()
    if exists("*LightlineGruvboxSetColors")
        call LightlineGruvboxSetColors()
    endif
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
    syntax enable

    if &background == 'dark'
        highlight GruvboxBgMed	ctermfg=234 guifg=#282828
        highlight Pmenu ctermfg=223 ctermbg=239 guifg=#ebdbb2 guibg=#282828
    else
        highlight GruvboxBgMed	ctermfg=229 guifg=#ebdbb2
        highlight Pmenu ctermfg=223 ctermbg=239 guifg=#282828 guibg=#ebdbb2
    endif

    " Customize fzf colors to match your color scheme
    let g:fzf_colors.bg = ['fg', 'GruvboxBgMed']
endfunction

augroup ResetColorscheme 
    autocmd!
    autocmd ColorScheme * call SetColors() 
augroup end

augroup CPPSettings
    autocmd!
    autocmd FileType cpp set tabstop=2 shiftwidth=2 softtabstop=2
    autocmd BufWritePre,FileWritePre *.cpp,*.h call CocAction('format')
    autocmd FileType cpp setlocal commentstring=//\ %s
augroup end

augroup RustSettings
    autocmd!
    autocmd FileType rust set tabstop=2 shiftwidth=2 softtabstop=2
    autocmd BufWritePre,FileWritePre *.rs call CocAction('format')
augroup end

augroup GoSettings
    autocmd!
    autocmd FileType go set tabstop=2 shiftwidth=2 softtabstop=2
    autocmd BufWritePre,FileWritePre *.go call CocAction('format')
augroup end

function! OpenWithName()
    call inputsave()
    let inp = input('Terminal name: ')
    call inputrestore()
    if !empty(inp)
        call termopen(&shell)
        execute 'keepalt file' expand('%:p').'/'.inp
    endif
endfunction


function! MapWinCmd(key, command, ...)
  if a:0 && a:1
    let suffix = ""
  else
    let suffix = "<cr>"
  endif

  "silent?
  execute "nnoremap <space>h".a:key." :<c-u>aboveleft vnew <bar>".
        \ a:command.suffix
  execute "nnoremap <space>j".a:key." :<c-u>belowright new <bar>".
        \ a:command.suffix
  execute "nnoremap <space>k".a:key." :<c-u>aboveleft new <bar>".
        \ a:command.suffix
  execute "nnoremap <space>l".a:key." :<c-u>belowright vnew <bar>".
        \ a:command.suffix
  " execute "nnoremap <space>;".a:key." :<c-u>call FloatingFullscreen()<cr>:".
  "       \ a:command.suffix
  execute "nnoremap <space>,".a:key." :<c-u>tabnew <bar>".
        \ a:command.suffix
  execute "nnoremap <space>.".a:key." :<c-u>".
        \ a:command.suffix
  execute "nnoremap <space>H".a:key." :<c-u>topleft vnew <bar>".
        \ a:command.suffix
  execute "nnoremap <space>J".a:key." :<c-u>botright new <bar>".
        \ a:command.suffix
  execute "nnoremap <space>K".a:key." :<c-u>topleft new <bar>".
        \ a:command.suffix
  execute "nnoremap <space>L".a:key." :<c-u>botright vnew <bar>".
        \ a:command.suffix
endfunction

call MapWinCmd("t", "terminal")
call MapWinCmd("T", "call OpenWithName()")
call MapWinCmd("e", " e ", 1)
call MapWinCmd("w", "enew <bar> setlocal bufhidden=hide nobuflisted " .
      \ "buftype=nofile")
call MapWinCmd("f", "Files")
call MapWinCmd("F", "Files ", 1)
call MapWinCmd("b", "Buffers")
call MapWinCmd("g", "GFiles")
call MapWinCmd("G", "GFiles ", 1)
call MapWinCmd("r", "RgPreviewHidden ", 1)
call MapWinCmd("R", "RgPreviewHidden")
call MapWinCmd(";r", "RgPreview ", 1)
call MapWinCmd(";R", "RgPreview")
call MapWinCmd("c", "normal! \<c-o>")
call MapWinCmd("s", "Startify")
call MapWinCmd("d", "e ~/.todo")

nnoremap <M-l> <C-w>l
nnoremap <M-h> <C-w>h
nnoremap <M-k> <C-w>k
nnoremap <M-j> <C-w>j

tnoremap <M-l> <C-\><C-n><C-w>l
tnoremap <M-h> <C-\><C-n><C-w>h
tnoremap <M-k> <C-\><C-n><C-w>k
tnoremap <M-j> <C-\><C-n><C-w>j


inoremap <c-f> <c-g>u<Esc>[s1z=`]a<c-g>u

augroup txt
  autocmd!
  autocmd FileType markdown,text,rst setlocal spell textwidth=100
augroup END

augroup todo
  autocmd!
  autocmd FileType todo setlocal wrap linebreak
augroup END

" autocmd BufRead,BufNewFile $HOME/CSM/* setlocal colorcolumn=0 tabstop=2 shiftwidth=2

function! FixSpellingMistake() abort
  let orig_spell_pos = getcurpos()
  normal! [s1z=
  call setpos('.', orig_spell_pos)
endfunction

nnoremap <c-f> <Cmd>call FixSpellingMistake()<cr>

function! SwitchColorScheme()
    let &background= ( &background == "dark"? "light" : "dark" )
    let command= &background == "dark"? "toggle_theme --dark" : "toggle_theme --light"
    call system(command)
    let $THEME=system("cat $HOME/.config/theme.yml")
endfunction

" Theme related
set termguicolors
let &background= ( system("cat $HOME/.config/theme.yml") =~ "light"? "light" : "dark" )
let g:gruvbox_contrast_light = "medium"
let g:gruvbox_contrast_dark = "hard"
colorscheme gruvbox
set pumblend=15
" set winblend=15


" Lightline 
let g:lightline = {}
let g:lightline.active = {
            \ 'left': [ [ 'mode', 'paste' ],
            \           [ 'readonly', 'filename', 'modified', 'cocstatus', 'conflictstatus'] ]}
let g:lightline.component_function = {'cocstatus': 'coc#status'}
let g:lightline.component_function = {'conflictstatus': 'ConflictedVersion'}
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

let g:lightline.colorscheme = 'gruvbox'
set noshowmode

call SetColors()

" Tab and Spaces related
set tabstop=4
set shiftwidth=4
set textwidth=0
set softtabstop=4
set expandtab
set foldlevel=99
let g:xml_syntax_folding=1

" UI related
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber number
augroup END
au TermOpen * setlocal listchars= nonumber norelativenumber

set inccommand=nosplit
set cursorline
set wildmenu
set autochdir 
set hidden
set wildmode=longest,list,full
set cmdheight=1
set ignorecase
set smartcase
set lazyredraw
set wrap
set colorcolumn=100
set undofile
set splitbelow
set splitright
set foldmethod=syntax

let g:vimtex_compiler_progname = 'nvr'
let g:tex_flavor  = 'latex'
let g:tex_conceal = ''
let g:vimtex_fold_manual = 1
let g:vimtex_latexmk_continuous = 1
let g:vimtex_view_method = 'zathura'

augroup vimtex_config
    au!
    au User VimtexEventQuit call vimtex#compiler#clean(0)
augroup END

let g:termdebug_wide = 1
packadd termdebug

" Fzf
let g:fzf_layout = { 'window': 'call FloatingFZF()' }
 

function! RgPreview(args, extra_args)
call fzf#vim#grep("rg --column --line-number --no-heading " .
      \ "--color=always --smart-case " . a:extra_args . " " .
      \ shellescape(a:args), 1, {'options' : 
      \ fzf#vim#with_preview('right:50%').options + 
      \ ['--bind', 'alt-e:execute-silent(remote_tab_open_grep {} &)']})
endfunction

function! RgPreviewHidden(args, extra_args)
call RgPreview(a:args, '--hidden --glob "!.git/*" ' . a:extra_args)
endfunction

command! -nargs=* RgPreview call RgPreview(<q-args>, '')
command! -nargs=* RgPreviewHidden call RgPreviewHidden(<q-args>, '')


" Files with preview
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let height = &lines - 15
  let width = float2nr(&columns - (&columns * 2 / 10))
  let row = float2nr((&lines - height) /2)
  let col = float2nr((&columns - width) / 2)

   let opts = {
         \ 'relative': 'editor',
         \ 'row': row,
         \ 'col': col,
         \ 'width': width,
         \ 'height': height
         \ }

  call nvim_open_win(buf, v:true, opts)
  setlocal
        \ buftype=nofile
        \ nobuflisted
        \ bufhidden=hide
        \ nonumber
        \ winblend=0
        \ pumblend=0
        \ norelativenumber
        \ signcolumn=no
endfunction


set conceallevel=1
let g:tex_conceal='admgs'

" move among buffers with CTRL
nnoremap <C-h> :bnext<CR>
nnoremap <C-l> :bprev<CR>
" Startify 
let g:startify_bookmarks = [
      \ {'z': '~/.zshrc'}, 
      \ {'v': '~/.config/nvim/init.vim'},
      \ {'w': '~/.config/regolith/i3/config'}, 
      \ {'x': '~/.config/regolith/Xresources'}, 
      \ {'s': '~/.config/regolith/i3xrocks/conf.d'},
      \ {'d': '~/.todo'}] 

let g:startify_commands = [
          \ {'t': 'terminal'},
          \ {'b': 'Buffers'},
          \ {'f': 'Files'}]

let g:startify_custom_header = ""
    let g:startify_lists = [
          \ { 'type': 'commands',  'header': ['   Commands']       },
          \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
          \ { 'type': 'files',     'header': ['   MRU']            },
          \ { 'type': 'sessions',  'header': ['   Sessions']       },
          \ ]
