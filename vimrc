call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'pbogut/fzf-mru.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'vim-airline/vim-airline'

call plug#end()

abbr Jaosn Jason
abbr Jsaon Jason
abbr bulid build
abbr hten then
abbr jsut just
abbr lamdba lambda
abbr taht that
abbr teh the
abbr thsi this
abbr yoru your

filetype indent plugin on

if has("syntax")
    syntax on
endif

set autoread
set backspace=2
set backupcopy=auto,breakhardlink
set directory=~/.tmp,.,/var/tmp
set expandtab
set formatoptions+=n
set grepformat=%f:%l:%c:%m
set grepprg=rg\ --sort=path\ --vimgrep\ "$@"
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
if version > 800
    set list
    set listchars=tab:➤·,trail:·,extends:➤
endif
set modeline
set nobackup
set noerrorbells
set nojoinspaces
set novisualbell
set ruler
set scrolloff=7
set shiftround
set shortmess=at
set showmatch
set smartcase
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L] 
set suffixes+=.class
set suffixes+=.pyc
set suffixes+=.pyo
set suffixesadd+=.go
set suffixesadd+=.js
set suffixesadd+=.jsx
set viminfo+=h
set wildmenu

" syntax-highlight #!/bin/sh as posix, not bourne, see
" http://www.pixelbeat.org/programming/shell_script_mistakes.html
let g:is_posix = 1

let c_gnu=1

let maplocalleader = ','
let mapleader = ','

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1

set background=dark
set confirm
set pastetoggle=<F8>

colorscheme jellybeans

" if started readonly, act like a pager
if &readonly
    nmap q :call Condexit()<CR>
    nmap b <C-b>
endif

function! Condexit ()
    if &readonly
        :q
    endif
endfunction

imap <S-Del> <BS>

map Q gq
ounmap Q

nmap <C-P> :FZF<cr>
nmap <Leader>m :FZFMru<cr>

nmap <Leader>ev :e $HOME/.vimrc<CR>
nmap <Leader>f :set fileformat=unix<CR>
nmap <Leader>g mZ:grep -w '<cword>'<CR><CR><CR>:copen<CR><CR>'Zz.
nmap <Leader>h :nohlsearch<CR>
nmap <Leader>p :let @" = expand("%")<cr>
nmap <Leader>s :source $HOME/.vimrc<CR>

nmap <C-q> @q
imap <C-B> {<CR>}
nmap :E :e
nmap :X :x
nmap :Q :q
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-h> <C-w>+
nmap <Home> gg
vmap <Home> gg
nmap <End> G
vmap <End> G
nmap <Space> <C-f>
nmap <C-e> :e#<CR>

vmap <Enter> <Plug>(EasyAlign)
nmap <Leader>a <Plug>(EasyAlign)

" copy/paste
imap <S-C-v> <esc>"+gpa
vmap <C-C> "+y

function! Dvorak ()
    noremap d h
    noremap co do
    noremap cp dp
    noremap n l
    noremap t gk
    ounmap t
    noremap h gj
    noremap e d
    noremap l n
    map <C-w>t <C-w>k
    ounmap <C-w>t
    map <C-w>h <C-w>j
    ounmap <C-w>h
endfunction

" Dvorak mappings
if $USER != 'root' || exists("$DVORAK")
    noremap j gj
    noremap k gk
    call Dvorak()
endif

" cycle buffers
nnoremap <C-n> :bn<CR>
nnoremap <BS> <C-^>

" vim: sw=4 et
