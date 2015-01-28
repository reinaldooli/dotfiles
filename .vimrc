set nocompatible
set t_Co=256
set background=dark
syntax on
" colorscheme darkwolf
" let g:solarized_termtrans=1

filetype off

set autoindent
set backspace=indent,eol,start
set backupdir=~/.vim/backups
set backupskip=/tmp/*,/private/tmp/*
set binary
set cursorline
set directory=~/.vim/swaps
set encoding=utf-8 nobomb
set esckeys
set expandtab
set exrc
set foldcolumn=4
set foldenable
set foldlevel=2
set foldmethod=syntax
set foldminlines=0
set foldnestmax=3
set gdefault
set guifont=Meslo
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lcs=tab:\|\ ,trail:·,extends:»,precedes:«,nbsp:_
set list
set noeol
set noerrorbells
set nostartofline
set number
set modeline
set modelines=4
set ruler
set scrolloff=3
set secure
set shiftwidth=4
set shortmess=atI
set showcmd
set showmode
set softtabstop=4
set ttyfast
set title
set wildmenu

set mouse=a
let mapleader=","

if exists("&undodir")
  set undodir=~/.vim/undo
endif

" if exists("&relativenumber")
"   set relativenumber
"   au BufReadPost * set relativenumber
" endif

" convert tabs to spaces before writing file
autocmd! bufwritepre * set expandtab | retab! 4

:hi CursorLine   cterm=NONE ctermbg=238 ctermfg=NONE guibg=238 guifg=NONE
:hi CursorColumn cterm=NONE ctermbg=238 ctermfg=NONE guibg=238 guifg=NONE
:nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
:highlight LineNr cterm=NONE ctermbg=NONE ctermfg=238 guibg=NONE guifg=238

execute pathogen#infect()
filetype plugin indent on

" vim-airline plugin configurations
let g:airline_powerline_fonts=1

" ultisnips vim plugin configurations
let g:UltiSnipsSnippetDirectories=["ultisnips"]

" indent-highlight plugin configurations
let g:indentLine_color_term=239
let g:indentLine_color_gui='#09AA08'
let g:indentLine_char='┆'

" supertab plugin configurations
" Remap autocomplete menu control keys
" inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
" inoremap <expr> j pumvisible() ? "\<C-n>" : "j"
" inoremap <expr> k pumvisible() ? "\<C-p>" : "k"
" inoremap <expr> h pumvisible() ? "\<PageUp>\<C-n>\<C-p>" : "h"
" inoremap <expr> l pumvisible() ? "\<PageDown>\<C-n>\<C-p>" : "l"
" let g:SuperTabCrMapping = 0 " prevent remap from breaking supertab
" let g:SuperTabDefaultCompletionType = "context"
" let g:SuperTabContextDefaultCompletionType = "<c-n>"
" set wildmode=list:longest,full
" let g:SuperTabClosePreviewOnPopupClose = 1 " close scratch window on autocompletion

" delimitMate plugin configurations
let delimitMate_expand_cr=1