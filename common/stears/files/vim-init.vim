" vim: set sts=2 ts=2 sw=2 expandtab :

" UTF-8 is always a better bet (especially with things like NERDTree on remote
" shells)
set encoding=utf-8

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

if has('unix')

  " NOTE: the double-slash at the end is deliberate, it tells vim to create
  " the file with its full path where slashes are changed to percent symbols,
  " and prevents clashes between files with the same name in different places
  " (happens a lot, e.g. with rust)

  " Move swp files
  set directory=~/tmp/

  " Move backup files
  set backupdir=~/tmp/
endif

" Philip: we always want a status line
set laststatus=2

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Philip's Settings:
set tw=0
set t_Co=256
set relativenumber
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set splitbelow splitright

" Use space instead of backslash
let mapleader = " "

" Buffer redraws (helps with things like relative line numbers, and just
" generally on remote shells)
set lazyredraw

" Stop ctrl-p from re-indexing across new instances of vim
let g:ctrlp_clear_cache_on_exit = 0

" Ignore .gitignore-d files
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" Tell ack.vim to use rg
let g:ackprg = 'rg --vimgrep --no-heading'

" Change to the current working directory if possible, or on Windows, the user
" profile dir as a fallback
if !empty($pwd)
	cd $pwd
elseif !empty($home)
	cd $home
elseif !empty($userprofile)
	cd $userprofile
endif

set guioptions-=T " No toolbar
set guioptions-=t " No tear-off menus

" ==============================================================================
" Dero: disable Purescript indentation
" ==============================================================================
let g:purescript_disable_indent = 1
autocmd FileType purs setlocal noai nocin nosi inde=

" ==============================================================================
" Dero: It's dirty, but this is an easy way to resize my windows
" ==============================================================================
nnoremap <C-left> :vertical resize -10<cr>
nnoremap <C-down> :resize +10<cr>
nnoremap <C-up> :resize -10<cr>
nnoremap <C-right> :vertical resize +10<cr>

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

 " Display-line based nav
nmap j gj
nmap k gk

inoremap <C-Space> <C-x><C-o>
inoremap <C-@> <C-x><C-o>

noremap <C-w><C-n> :vnew<cr>
noremap <C-w><C-s> :vsplit<cr>
noremap <C-n> :NERDTree<cr>

nmap <F8> :TagbarToggle<CR>

" Enable true-colour
if (has("termguicolors"))
 set termguicolors
endif

" ==============================================================================
" Color Scheme Stuff Originally Taken from Rob
" ==============================================================================
"
"Gotta do it this way or the theme won't get loaded"
function! SetDarkTheme()
  " colorscheme molokai
  colorscheme tender
  highlight clear SignColumn

  " TODO: assign proper colours rather than linking to random things
  highlight link LspDiagnosticsSignError SpellBad
  highlight link LspDiagnosticsSignWarn SpellCap
  highlight link LspDiagnosticsSignHint SpellCap
  highlight link LspDiagnosticsSignInfo SpellRare

  " Colours from molokai for floating windows,
  " because tender's are unreadable
  hi Pmenu           guifg=#66D9EF guibg=#000000
  hi PmenuSel                      guibg=#808080
  hi PmenuSbar                     guibg=#080808
  hi PmenuThumb      guifg=#66D9EF
endfunction

" Having a change of scenery
function! SetLightTheme()
  colorscheme default
  highlight NonText ctermfg=black
  highlight VertSplit cterm=none gui=none
  highlight clear SignColumn
  highlight CursorLine cterm=none ctermbg=lightgrey
  highlight LineNr ctermfg=darkgrey
  highlight StatusLine ctermfg=darkblue ctermbg=white
  highlight StatusLineNC ctermfg=darkgrey ctermbg=blue
endfunction

function! SetSolarized()
  set background=dark
  colorscheme solarized
endfunction

function! Presentation()
  if !empty(glob(".pres"))
    set norelativenumber
    hi clear CursorLine
    hi clear Cursor
    hi clear CursorColumn
    set norelativenumber
    let g:airline#extensions#tabline#enabled = 0
    let g:loaded_airline = 0
    let s:hidden_all = 1
    set noshowmode
    set noruler
    set laststatus=0
    set noshowcmd
  endif
endfunction

" This is a bit cheeky, but it's pretty useful when in Thailand
function! Daytime()
  colorscheme default
  set guifont=Ubuntu\ Mono\ 14
endfunction

augroup theming
  autocmd!
  autocmd VimEnter * call SetDarkTheme()
augroup END

if has("gui_running")
  if has("gui_gtk2")
    set guifont=Droid\ Sans\ Mono\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=Consolas:h11:cANSI
  endif
endif

" Show autocompletion alternatives for ex commands
set wildmenu

" Exclude certain file types from fuzzy matching
set wildignore+=*.o,*.d,*.bin,*.elf,*.sys,*.BIN,*.ELF,*.SYS,*.img,*.IMG,*.beam

" Down with trailing whitespace!
autocmd BufWritePre * :%s/\s\+$//e

" Enable exiting insert mode in a terminal by pressing escape
tnoremap <Esc> <C-\><C-n>

" ----------------------------------------------------------------------------
" LSP config
" ----------------------------------------------------------------------------
source ~/.config/nvim/init-extra.lua
set updatetime=300

" Format on save
augroup AutoActionsLsp
  autocmd!
  autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()
augroup END

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

" Reserve space for the errors
set signcolumn=auto

let g:dap_virtual_text = v:true

" Rainbow parens
au FileType rust call rainbow#load()
