" All system-wide defaults are set in $VIMRUNTIME/archlinux.vim (usually just
" /usr/share/vim/vimfiles/archlinux.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vimrc), since archlinux.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing archlinux.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages.
" runtime! archlinux.vim

" If you prefer the old-style vim functionalty, add 'runtime! vimrc_example.vim'
" Or better yet, read /usr/share/vim/vim80/vimrc_example.vim or the vim manual
" and configure vim to your own liking!

" do not load defaults if ~/.vimrc is missing
"let skip_defaults_vim=1

" :set virtualedit=onemore


set clipboard+=unnamedplus

" Plugins
call plug#begin('~/.local/share/nvim/plugged')

Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'gruvbox-community/gruvbox' 
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
Plug 'neevparikh/lightline-gruvbox.vim'

call plug#end()

" Vimtex
let g:vimtex_fold_enabled = 1 
let g:vimtex_format_enabled = 1

" Autocomplete
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

" Lightline 
let g:lightline = {}
let g:lightline.colorscheme = 'gruvbox'
let g:lightline.active = {
            \ 'left': [ [ 'mode', 'paste' ],
            \           [ 'readonly', 'filename', 'modified', 'cocstatus' ] ]}

let g:lightline.component_function = {'cocstatus': 'coc#status'}
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
set noshowmode

" UltiSnips
" let g:UltiSnipsUsePythonVersion = 3

" Remapping
let mapleader=','
nmap <space>s <cmd>source %<cr> 
tnoremap <M-space> <C-\><C-n>
nmap <M-w> <C-w>
nnoremap <M-space> :Startify<CR>
nnoremap <M-b> :Buffers<CR>
nnoremap <M-f> :Files<CR>
nnoremap <M-t> :terminal<CR>
nnoremap <M-F> :Files ../<CR>
nnoremap <M-c> :call SwitchColorScheme()<CR>
nmap <M-n> <Plug>(coc-diagnostic-next)<CR>
nmap <M-p> <Plug>(coc-diagnostic-prev)<CR>
nmap <space>f <Plug>(coc-format-selected)<CR>
nmap <space>F <Plug>(coc-format)<CR>

function! SetColors()
    let g:lightline.colorscheme = substitute(substitute(g:colors_name, '-', '_', 'g'), '256.*', '', '') . 
                \ (g:colors_name ==# 'solarized' ? '_' . &background : '')
    if exists("*LightlineGruvboxSetColors")
        call LightlineGruvboxSetColors()
    endif
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()

    if &background == 'dark'
        hi GruvboxBgMed	ctermfg=234 guifg=#282828
    else
        hi GruvboxBgMed	ctermfg=229 guifg=#ebdbb2
    endif

    " Customize fzf colors to match your color scheme
    let g:fzf_colors.bg = ['fg', 'GruvboxBgMed']
endfunction

augroup ResetColorscheme 
    autocmd!
    autocmd ColorScheme * call SetColors() 
augroup end


function! SwitchColorScheme()
    let &background= ( &background == "dark"? "light" : "dark" )
endfunction

" Theme related
set termguicolors
set background=dark
let g:gruvbox_contrast_dark = "hard"
colorscheme gruvbox
syntax enable
call SetColors()

" Tab and Spaces related
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set ai
set foldlevel=99

" UI related
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber number
augroup END

set cursorline
filetype plugin on
filetype indent on
set wildmenu
set hidden
set wildmode=longest,list,full
set showmatch
set wildignore+=*/.git/*,*/.hg/*,/*/.svn/*,*/.DS_Store
set ruler
set cmdheight=1
set smartcase
set lazyredraw
set wrap
set showcmd
set undofile
set splitbelow
set splitright
set foldmethod=syntax
autocmd Filetype <your-filetype> AnyFoldActivate

let g:vimtex_compiler_progname = 'nvr'
let g:tex_flavor  = 'latex'
let g:tex_conceal = ''
let g:vimtex_fold_manual = 1
let g:vimtex_latexmk_continuous = 1
let g:vimtex_view_method = 'zathura'

" Fzf
let g:fzf_layout = { 'window': 'call FloatingFZF()' }
 

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
        \ norelativenumber
        \ signcolumn=no
endfunction

" Searching related
" set incsearch
" set hlsearch
nnoremap <leader><space> :nohlsearch<CR>

" move among buffers with CTRL
nnoremap <C-h> :bnext<CR>
nnoremap <C-l> :bprev<CR>
" Startify 
let g:startify_bookmarks = [
      \ {'z': '~/.zshrc'}, 
      \ {'v': '~/.config/nvim/init.vim'},
      \ {'w': '~/.config/i3/config'}, 
      \ {'s': '~/.config/i3status/config'}] 

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
