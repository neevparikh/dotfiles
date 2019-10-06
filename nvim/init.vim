set clipboard+=unnamedplus

" Plugins
filetype off
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
Plug '/lightline-gruvbox.vim'
Plug 'neevparikh/lightline-gruvbox.vim'
Plug 'simnalamburt/vim-mundo'
Plug 'unblevable/quick-scope'
Plug 'wellle/targets.vim'
Plug 'unblevable/quick-scope'
Plug 'bfredl/nvim-miniyank'
Plug 'machakann/vim-highlightedyank'
Plug 'airblade/vim-rooter'

call plug#end()
filetype indent plugin on

" Vimtex
let g:vimtex_fold_enabled = 1 
let g:vimtex_format_enabled = 1

let g:coc_global_extensions = [
            \ 'coc-snippets', 
            \ 'coc-vimlsp',
            \ 'coc-dictionary',
            \ 'coc-word',
            \ 'coc-syntax',
            \ 'coc-git', 
            \ 'coc-python',
            \ 'coc-json',
            \ 'coc-vimtex']

" Autocomplete
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

xmap <Tab> <Plug>(coc-snippets-select)

nmap p <Plug>(miniyank-autoput)
nmap P <Plug>(miniyank-autoPut)
xmap p <Plug>(miniyank-autoput)
xmap P <Plug>(miniyank-autoPut)

nmap <space>n <Plug>(miniyank-cycle)
nmap <space>N <Plug>(miniyank-cycleback)

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
nmap <space>s <cmd>source %<cr> 
tnoremap <M-space> <C-\><C-n>
nmap <M-w> <C-w>
nnoremap <M-space> :Startify<CR>
nnoremap <M-b> :Buffers<CR>
nnoremap <M-f> :Files<CR>
nnoremap <M-t> :terminal<CR>
nnoremap <M-F> :Files ../<CR>
nnoremap <M-c> :call SwitchColorScheme()<CR>
nmap <M-n> <Plug>(coc-diagnostic-next)
nmap <M-p> <Plug>(coc-diagnostic-prev)
nmap <space>f <Plug>(coc-format-selected)
nmap <space>F <Plug>(coc-format)
nmap <space>d <Plug>(coc-definition)
nnoremap <K> :call doHover()<CR>
xnoremap <K> :call doHover()<CR>

function! SetColors()
    let g:lightline.colorscheme = substitute(substitute(g:colors_name, '-', '_', 'g'), '256.*', '', '') . 
                \ (g:colors_name ==# 'solarized' ? '_' . &background : '')
    if exists("*LightlineGruvboxSetColors")
        call LightlineGruvboxSetColors()
    endif
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
    syntax enable

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
call SetColors()
set pumblend=15
set winblend=15

" Tab and Spaces related
set tabstop=4
set shiftwidth=4
set textwidth=0
set softtabstop=4
set expandtab
set foldlevel=99

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
