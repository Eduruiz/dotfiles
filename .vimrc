set nocompatible              " be iMproved, required

so ~/.vim/plugins.vim

let mapleader = ',' 						    	"The default is \, but a comma is much better.


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Powerline config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set utf-8
set enc=utf-8
syntax enable on

let g:Powerline_symbols = 'fancy'
set laststatus=2 "always sho powerline
set encoding=utf-8
set t_Co=256
let g:airline_powerline_fonts = 1
set fillchars+=stl:\ ,stlnc:\
set termencoding=utf-8
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" Just show the filename (no path) in the tab
let g:airline#extensions#tabline#fnamemod = ':t'



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

"Always show current position
set ruler

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

"no textwrap
set nowrap

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

"custom ctrl+p ignore pattern
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn))$'


"NerdTREE show hidden files
let NERDTreeShowHidden=1

" tell it to use an undo file
set undofile
" set a directory to store the undo history
set undodir=~/.vim/undo

"remap Gundo key
nnoremap <F5> :GundoToggle<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
set ai "Auto indent
set si "Smart indent
set nowrap "no wrap text
" making clipboard unnamed to work with os clipboard
set clipboard=unnamed

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Syntastic plugin base config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"let g:syntastic_quiet_messages = { "type": "style" }
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Remaps
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap ; :
map <F2> :NERDTreeToggle<CR>

vmap  <expr>  <LEFT>   DVB_Drag('left')
vmap  <expr>  <RIGHT>  DVB_Drag('right')
vmap  <expr>  <DOWN>   DVB_Drag('down')
vmap  <expr>  <UP>     DVB_Drag('up')
vmap  <expr>  D        DVB_Duplicate()



"-------------Jeff stuff I'm learning--------------"

set autowriteall                                                        "Automatically write the file when switching buffers.
set belloff=all                                                         "Disable annoing noise on gvim




"-------------Visual stuff--------------"
:set formatoptions-=t                                                   "Disable vim auto indentation on some width
let g:enable_italic_font = 1                                            "Enable italic fonts on comments
"let g:enable_bold_font = 1                                             "Enable some fonts to be bold
set background=dark
colorscheme hybrid_material
let g:airline_theme = "hybrid"                                          "Enable hibryd theme on airline 
set guioptions-=m                                                       "remove menu bar
set guioptions-=T                                                       "remove toolbar
set guioptions-=r                                                       "remove right-hand scroll bar
set guioptions-=L                                                       "remove left-hand scroll bar
set number                                                              "show line numbers
set smartindent                                                         "when new line on insert mode, keep indentation



"-------------Split Management--------------"
set splitbelow                           								"Make splits default to below...
set splitright							                            	"And to the right. This feels more natural.

"We'll set simpler mappings to switch between splits.
nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-H> <C-W><C-H>
nmap <C-L> <C-W><C-L>




"-------------History and undo stuff--------------"
set history=1000                                                         " Store a ton of history
set undofile                                                            "Turn on the feature, this make persistend undo after writing file
set undodir=$HOME/.vim/undo                                             "Directory where the undo files will be stored, this NEED to exist beforehand




"-------------Plugins--------------"

"/
"/ GitGutter
"/

"let g:gitgutter_override_sign_column_highlight = 1
highlight clear SignColumn                                               "Use same color from editor bg on git gutter column

if exists('&signcolumn')                                                 "Vim 7.4.2201 always show the gitgutter padding on the left
  set signcolumn=yes
else
  let g:gitgutter_sign_column_always = 1
endif



"-------------Setting gui only configs--------------"
if has("gui_running")
      "set guifont=Source\ Code\ Pro\ for\ Powerline:h16                 "setting a nice fonts on gui vim
      set guifont=Fira\ Code\ 13                 "setting a nice fonts on gui vim
      if has("gui_macvim")
        set fu                                                            "enter fulscreen
      endif
endif





"-------------Mappings--------------"
"Make it easy to edit the Vimrc file.
nmap <Leader>ev :tabedit $MYVIMRC<cr>
nmap <Leader>es :e ~/.vim/snippets/

"Add simple highlight removal.
nmap <Leader><space> :nohlsearch<cr>

"Quickly browse to any tag/symbol in the project.
"Tip: run ctags -R to regenerated the index.
nmap <Leader>f :tag<space>

"Easy scape from insert mode
inoremap jk <esc>
inoremap kj <esc>



"-------------Auto-Commands--------------"
"Automatically source the Vimrc file on save.

augroup autosourcing
	autocmd!
	autocmd BufWritePost .vimrc source %
augroup END
