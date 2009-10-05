"
" Load Debian paths/etc when applicable
"

runtime! debian.vim


"
" Basic/common settings
"

" Colorization/display

" Syntax highlighting!
syntax on
colorscheme evening
" Colorize for a dark background
set background=dark
" Show ruler line at bottom of each buffer
set ruler
" Show additional info in the command line (very last line on screen) where
" appropriate.
set showcmd
" Always display status lines/rulers
set laststatus=2

" Navigation/search

" Show matching brackets/parentheses when navigating around
set showmatch
" Show matching parens in 2/10 of a second. No idea why I wanted this.
set matchtime=2
" Search incrementally instead of waiting for me to hit Enter
set incsearch
" Search case-insensitively
set ignorecase
" But be smart about it -- if I have any caps in my term, be case-sensitive.
set smartcase
" Don't highlight search terms by default.
set nohls

" Formatting

" Automatically indent based on current filetype
set autoindent
" Don't unindent when I press Enter on an indented line
set preserveindent
" 'smartindent', however, screws up Python -- so turn it off
set nosmartindent
" Make tabbing/deleting honor 'shiftwidth' as well as 'softtab' and 'tabstop'
set smarttab
" Use spaces for tabs
set expandtab
" When wrapping/formatting, break at 79 characters. 
set textwidth=79
" By default, all indent/tab stuff is 4 spaces, as God intended.
set tabstop=4
set softtabstop=4
set shiftwidth=4
" Default autoformatting options:
" t: automatically hard-wrap based on textwidth
" c: do the same for comments, but autoinsert comment character too
" r: also autoinsert comment character when making new lines after existing
"    comment lines
" o: ditto but for o/O in normal mode
" q: Allow 'gq' to autowrap/autoformat comments as well as normal text
" n: Recognize numbered lists when autoformatting (don't explicitly need this,
"    was probably in a default setup somewhere.)
" 2: Use 2nd line of a paragraph for the overall indentation level when
"    autoformatting. Good for e.g. bulleted lists or other formats where first
"    line in a paragraph may have a different indent than the rest.
set formatoptions=tcroqn2 
" Try to break on specific characters instead of the very last character that
" might otherwise fit. Don't remember exactly why this is here but I'm happy
" with how things wrap now...
set lbr

" Behavior

" Allow folding to play nice with Python and other well-indented code
set foldmethod=indent
" Don't close all folds by default when file opens
set nofoldenable
" "/bin/bash -l -c <command>" for :sh and :!
" (so it sources my .bashrc and so forth)
set shellcmdflag=-c
set shell=bash\ -l
" Honor Vim modelines at top/bottom of files
set modeline
" Look 5 lines in for modelines (default is sometimes just 1 or 2 which may not
" be enough for some files)
set modelines=5
" When splitting, put new window on the right hand side
set splitright
" Start scrolling up/down when cursor gets to 3 lines away from window edge
set scrolloff=3
" Don't use 'more' for shell output automatically.
set nomore
" Use bash-like tab completion in Vim command line
set wildmenu
set wildmode=list:longest
" Allow backspaces to eat indents, end-of-line/beginning-of-line characters
set backspace=indent,eol,start
" Let me open a shitton of tabs at once if I really want.
set tabpagemax=100
" Make :sb let me navigate between all windows and tabs
set switchbuf=usetab

" Jump to last known location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

" Filetype based indent rules
if has("autocmd")
  filetype indent plugin on
endif


"
" Settings for specific versions of Vim
"

" MacVim
if has("gui_macvim")
    set transparency=15
    set guifont=Inconsolata-dz:h12
    set lines=60
    set formatoptions-=t
    set formatoptions-=c
endif


"
" Settings for specific filetypes
"

" Ruby
autocmd FileType ruby setlocal tabstop=2 softtabstop=2 shiftwidth=2 foldmethod=syntax

" Markdown
autocmd FileType mkd setlocal ai comments=n:>

" ReST
autocmd BufRead *.rst setlocal filetype=rest
autocmd FileType rest setlocal ai comments=n:>

" YAML
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 softtabstop=2

" No more need to drop modelines into common Apache files
" (both Debian and RedHat style Apache conf dirs)
autocmd BufRead /etc/apache2/*,/etc/httpd/* setlocal filetype=apache


"
" Key mappings
"

" Up/down go visually instead of by physical lines (useful for long wraps)
" Interactive ones need to check whether we're in the autocomplete popup (which
" breaks if we remap to gk/gj)
map <up> gk
inoremap <up> <C-R>=pumvisible() ? "\<lt>up>" : "\<lt>C-o>gk"<Enter>
map <down> gj
inoremap <down> <C-R>=pumvisible() ? "\<lt>down>" : "\<lt>C-o>gj"<Enter>

" Custom mapping shortcut for :nohl
nmap <C-N> :noh<CR>

" Map normal mode Enter to add a new line.
" Useful for adding spacing to a file while navigating.
nmap <Enter> o<Esc>


"
" netrw (builtin file-browser plugin) preferences
"

" Default to tree view 
let g:netrw_liststyle = 3
" Hide common hidden files
let g:netrw_list_hide = '.*\.py[co]$,\.git$,\.swp$'


"
" Custom "snippets"/shortcuts
"

function! NextLineIsOnly(char)
    return getline(line(".")+1) =~ "^" . a:char . "\\+$"
endf

function! ReplaceNextLineWith(char)
    return "yyjVpVr" . a:char
endf

function! ReplaceSurroundingsWith(char)
    return ReplaceNextLineWith(a:char) . "yykkVp"
endf

function! AppendLineOf(char)
    return "yypVr" . a:char
endf

function! SurroundWith(char)
    return AppendLineOf(a:char) . "yykP"
endf

function! H1()
    let char = "="
    if NextLineIsOnly(char)
        return ReplaceSurroundingsWith(char)
    else
        return SurroundWith(char)
    endif
endf

function! H(char)
    if NextLineIsOnly(a:char)
        return ReplaceNextLineWith(a:char)
    else
        return AppendLineOf(a:char)
    endif
endf

nnoremap <expr> <F1> H1()
nnoremap <expr> <F2> H("=")
nnoremap <expr> <F3> H("-")
