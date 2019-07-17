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


set clipboard=unnamedplus

" Plugins
call plug#begin('~/.local/share/nvim/plugged')

" Deoplete
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'morhetz/gruvbox' 
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

call plug#end()

" Vimtex
let g:vimtex_fold_enabled = 1 
let g:vimtex_format_enabled = 1

" Autocomplete
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

" Lightline 
let g:lightline = {'colorscheme': 'gruvbox'}
let g:lightline.active = {
            \ 'left': [ [ 'mode', 'paste' ],
            \           [ 'readonly', 'filename', 'modified', 'cocstatus' ] ]}

let g:lightline.component_function = {'cocstatus': 'coc#status'}

" Remapping
let mapleader=','
nmap <space>s <cmd>source %<cr> 
tnoremap <M-space> <C-\><C-n>
nmap <M-w> <C-w>
nnoremap <M-space> :Startify<CR>

" Theme related
set termguicolors
set background=dark
let g:gruvbox_contrast_dark = "hard"
colorscheme gruvbox
syntax enable

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
set foldmethod=expr

" Fzf
let g:fzf_layout = { 'right': '~30%' }

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