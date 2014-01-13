" Use Vim settings, rather then Vi settings (much better!).
" " This must be first, because it changes other options as a side effect.
set nocompatible

" =============== Encoding ===============
set encoding=utf-8

"
" TODO: this may not be in the correct place. It is intended to allow overriding <Leader>.
" source ~/.vimrc.before if it exists.
if filereadable(expand("~/.vimrc.before"))
  source ~/.vimrc.before
endif

" =============== Pathogen Initialization ===============
" This loads all the plugins in ~/.vim/bundle
" Use tpope's pathogen plugin to manage all other plugins

runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

" ================ General Config ====================

set number 				"Line numbers are good
set backspace=indent,eol,start 		"Allow backspace in insert mode
set history=1000 			"Store lots of :cmdline history
set showcmd 				"Show incomplete cmds down the bottom
set showmode 				"Show current mode down the bottom
set gcr=a:blinkon0 			"Disable cursor blink
set visualbell 				"No sounds
set autoread 				"Reload files changed outside vim

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" ================ Status Line ====================
set laststatus=2
set statusline=   " clear the statusline for when vimrc is reloaded
set statusline+=%-3.3n\                      " buffer number
set statusline+=%<%.40f\                     " file name
set statusline+=%h%m%r%w                     " flags
set statusline+=[%{strlen(&ft)?&ft:'none'},  " filetype
set statusline+=%{strlen(&fenc)?&fenc:&enc}, " encoding
set statusline+=%{&fileformat}]              " file format
set statusline+=%=                           " right align
set statusline+=%{synIDattr(synID(line('.'),col('.'),1),'name')}\  " highlight
set statusline+=%b,0x%-8B\                   " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset


" ================ Key Settings ====================

" Toggle line number with F2
nnoremap <F2> :set number! number?<CR>

" Toggle line number with F3
nnoremap <F3> :set paste! paste?<CR>
imap <F3> <C-O>:set paste! paste?<CR>
set pastetoggle=<F3>

" Press F4 to toggle highlighting on/off, and show current value.
nnoremap <F4> :set hlsearch! hlsearch?<CR>

" Press F5 to toggle background
call togglebg#map("<F5>")

" Tab navigation
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . tabpagenr()<CR>

" Press 2xESC to toggle highlighting off
nnoremap <ESC><ESC> :nohlsearch<CR>


" ================ Search Settings =================

set incsearch 			"Find the next match as we type the search
set hlsearch 			"Highlight searches by default
set showmatch                   "highlight searches
  set matchtime=3
set viminfo='100,f1 		"Save up to 100 marks, enable capital marks

" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.

set undolevels=10000

if exists("+undofile")
  silent !mkdir ~/.vim/undo > /dev/null 2>&1
  set undodir=~/.vim/undo
  set undofile
endif

" ================ Indentation ======================

set autoindent
"set smartindent
"set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

filetype plugin on
filetype indent on

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

set nowrap 			"Don't wrap lines
set linebreak 			"Wrap lines at convenient points

" ================ Folds ============================

set foldmethod=indent 			"fold based on indent
set foldnestmax=3 			"deepest fold is 3 levels
set nofoldenable 			"dont fold by default

" ================ Completion =======================

 set wildmode=list:longest
 set wildmenu 				          "enable ctrl-n and ctrl-p to scroll thru matches
 set wildignore=*.o,*.obj,*~ 		"stuff to ignore when tab completing
 set wildignore+=*vim/backups*
 set wildignore+=*sass-cache*
 set wildignore+=*DS_Store*
 set wildignore+=vendor/rails/**
 set wildignore+=vendor/cache/**
 set wildignore+=*.gem
 set wildignore+=log/**
 set wildignore+=tmp/**
 set wildignore+=*.png,*.jpg,*.gif


" ================ Scrolling ========================

 set scrolloff=8 			"Start scrolling when we're 8 lines away from margins
 set sidescrolloff=15
 set sidescroll=1


" ================ Color ========================

 let &colorcolumn="80,".join(range(81,999),",")
 let &colorcolumn="80,".join(range(120,999),",")
 :highlight ColorColumn ctermbg=LightGrey guibg=#424242 ctermfg=black guifg=white

 "set railscasts colorscheme when running vim with gui
 let g:solarized_visibility= "normal"
 let g:solarized_bold = 1
 
 if has("gui_running")
     " set term=gnome-256color
     colorscheme railscasts
 else
     let g:solarized_termcolors=256
     set background=light
     colorscheme solarized
 endif

 
" ================ Plugins ========================
  " NerdTree
  nnoremap <C-g> :NERDTreeToggle<cr>
  let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$', '\.o$', '\.so$', '\.egg$', '^\.git$' ]
  let NERDTreeHighlightCursorline=1
  let NERDTreeShowBookmarks=1
  let NERDTreeShowFiles=1
