set nocompatible                                    "Always use latest version of vim (I think)

so ~/.vim/plugins.vim

let mapleader = ',' 						    	"The default is \, but a comma is much better.


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
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|jpg|png|gif|ico|git|svn))$'


"remap Gundo key
nnoremap <F5> :GundoToggle<CR>

" making clipboard unnamed to work with os clipboard
set clipboard=unnamed


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Remaps
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"-------------Jeff stuff I'm learning--------------"

set hidden                                                              "Automatically write the file when switching buffers.
set belloff=all                                                         "Disable annoing noise on gvim
set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4
set ff=unix                                                             "Auto-convert line breaking in unix like
set autoread                                                            "Automatically reread changed files without asking me anything
set showmatch                                                           "Do not show matching brackets by flickering
let php_htmlInStrings = 1



"-------------Visual stuff--------------"
:set formatoptions-=t                                                   "Disable vim auto indentation on some width
let g:enable_italic_font = 1                                            "Enable italic fonts on comments
"let g:enable_bold_font = 1                                             "Enable some fonts to be bold
set background=dark
colorscheme OceanicNext
let g:airline_theme = "oceanicnext"                                          "Enable hibryd theme on airline 
set guioptions-=m                                                       "remove menu bar
set guioptions-=T                                                       "remove toolbar
set guioptions-=r                                                       "remove right-hand scroll bar
set guioptions-=L                                                       "remove left-hand scroll bar
set number                                                              "show line numbers
set smartindent                                                         "when new line on insert mode, keep indentation
set cursorline                                                          "highlight current line under cursor
set termguicolors
autocmd ColorScheme * highlight clear LineNr | highlight clear SignColumn "Use same color from editor bg on git gutter column




set number relativenumber

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
set undodir=$HOME/.vim/undo//                                            "Directory where the undo files will be stored, this NEED to exist beforehand




"-------------Plugins--------------"

"/
"/ GitGutter
"/

let g:gitgutter_override_sign_column_highlight = 0
highlight clear SignColumn                                               "Use same color from editor bg on git gutter column




if exists('&signcolumn')                                                 "Vim 7.4.2201 always show the gitgutter padding on the left
  set signcolumn=yes
else
  let g:gitgutter_sign_column_always = 1
endif





"/
"/ vim sessions
"/
let g:session_autosave = 'yes'                                            "autosave session on quit
let g:session_autoload = 'no'                                            "get rid of dialog asking if you want to load the last session
let g:session_default_to_last = 1                                         "autoload last saved session




"/
"/ ultisnips
"/
" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:SuperTabDefaultCompletionType = '<C-n>'

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
filetype plugin indent on

"/
"/ Ctrl+P
"/

"let g:ctrlp_cmd = 'CtrlPMixed'			" search anything (in files, buffers and MRU files at the same time.)
let g:ctrlp_working_path_mode = 'ra'	        " search for nearest ancestor like .git, .hg, and the directory of the current file
" let g:ctrlp_by_filename = 1
let g:ctrlp_max_height = 10			" maxiumum height of match window
let g:ctrlp_switch_buffer = 'et'		" jump to a file if it's open already
let g:ctrlp_use_caching = 1			" enable caching
let g:ctrlp_clear_cache_on_exit=0  		" speed up by not removing clearing cache evertime
let g:ctrlp_mruf_max = 250 			" number of recently opened files
let g:ctrlp_show_hidden = 1                     " let ctrlp see the hidden files

"/
"/ fzf
"/
" Tell ack.vim to use ag (the Silver Searcher) instead
nmap <Leader>b :Buffers<CR>
nmap <Leader>f :Files<CR>
nmap <Leader>t :Tags<CR>




"/
"/ AckVim
"/
" Tell ack.vim to use ag (the Silver Searcher) instead
let g:ackprg = 'ag --vimgrep'





"/
"/ Emmet vim
"/
" let g:user_emmet_expandabbr_key='<Tab>'     "expand stuff using tab from emmet (st like)
"autocmd FileType html,css,scss,sass EmmetInstall "configure emmet to run on those expecific filetypes
let g:user_emmet_mode='i' "only use emmet on insert mode
let g:user_emmet_next_key = '<C-e>'
"let g:user_emmet_prev_key = '<S-Tab>'



"/
"/ syntastic
"/

let g:syntastic_always_populate_loc_list = 1     "Those are the recommended settings from syntastic
let g:syntastic_auto_loc_list = 1                "I don't really know what's going on here, but will
let g:syntastic_check_on_open = 1                "update as soon as things make more sense to me
let g:syntastic_check_on_wq = 0






"/
"/ ALE - syntax linting assync
"/
let g:ale_sign_warning = '▲'
let g:ale_sign_error   = '✗'
highlight link ALEWarningSign String
highlight link ALEErrorSign Title





"/
"/ nerdtree
"/
let NERDTreeShowHidden=1




"/
"/ airline
"/

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





"/
"/ vim-jsx (react syntax for vim)
"/
let g:jsx_ext_required = 0 " Allow JSX in normal JS files





"/
"/ vim-multiple-cursos
"/
let g:multi_cursor_exit_from_insert_mode = 0


"/
"/ javascript libraries
"/

let g:used_javascript_libs = 'jquery,vue,react'


"-------------Setting gui only configs--------------"
if has("gui_running")
      if has("gui_macvim")
        set fu                                                            "enter fulscreen
        set guifont=Fira\ Code:h14                                        "setting a nice fonts on gui vim on mac
      else
        set guifont=Fira\ Code\ 13                                        "setting a nice fonts on gui vim on linux
      endif
endif




"-------------Setting nvim only configs--------------"
if has('nvim')
    " Make replace visual on nvim
    set inccommand=nosplit
endif





"-------------Mappings--------------"
"Make it easy to edit the vim file.
nmap <Leader>ev :e ~/.vimrc<cr>
nmap <Leader>ep :e ~/.vim/plugins.vim<cr>
nmap <Leader>es :e ~/.vim/snippets/

"Add simple highlight removal.
nmap <Leader><space> :nohlsearch<cr>

"Quickly browse to any tag/symbol in the project.
"Tip: run ctags -R to regenerated the index.
" nmap <Leader>f :tag<space>

"Easy scape from insert mode
inoremap jk <esc>
inoremap kj <esc>
inoremap jj <esc>
inoremap kk <esc>

"Easy scape from terminal mode
tnoremap <esc> <C-\><C-N>

"easy use of ; as : no need to use shift :)
nnoremap ; :


"remap ctrl+s to save, not really 'vim way', but I'm used to
nmap <c-s> :w<cr>
imap <c-s> <esc>:w<cr>a


"quick open e close NerdTREE
map <F2> :NERDTreeToggle<CR>                                                 

"drag and dupliscate selected text with arrow keys
vmap  <expr>  <LEFT>   DVB_Drag('left')                                     
vmap  <expr>  <RIGHT>  DVB_Drag('right')
vmap  <expr>  <DOWN>   DVB_Drag('down')
vmap  <expr>  <UP>     DVB_Drag('up')
vmap  <expr>  D        DVB_Duplicate()


" Toggle spellcheck on and of with key shortcut
:map <F3> :setlocal spell! spelllang=en_us<CR>

"adjust tab to indent on insert mode, needed because tab is remmaped to expand emmet sutff
" imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")


"-------------Laravel-Specific--------------"
nmap <Leader>lr :e routes/web.php<cr>
nmap <Leader>lm :!php artisan make:
nmap <Leader><Leader>c :e app/Http/Controllers/<cr>
nmap <Leader><Leader>m :CtrlP<cr>app/
nmap <Leader><Leader>v :e resources/views/<cr>





"-------------Codeigniter-Specific--------------"
"open config.php file in application/config or in app/application/config
nnoremap <expr> <Leader>cc !empty(glob("application/config/config.php")) ? ':e application/config/config.php<cr>' : ':e app/application/config/config.php<cr>'
"open routes.php file in application/config or in app/application/config
nnoremap <expr> <Leader>cr !empty(glob("application/config/routes.php")) ? ':e application/config/routes.php<cr>' : ':e app/application/config/routes.php<cr>'



"-------------Auto-Commands--------------"
"automatically source the vimrc file on save.
"ok, let's break this in parts - first pip is sourcing vimrc,
"seconde one is clearing line numbers, so it get the same color as the bg
"third one is doing the same, but with SignColumn (used by gitgutter)
"fourth one is refreshing airline, so the tabs don't loose it's colors
autocmd! bufwritepost ~/.vimrc source ~/.vimrc | highlight clear LineNr | AirlineRefresh | highlight clear SignColumn


"automatically jump to last know cursor position on file
if v:version >= 700
  au BufLeave * let b:winview = winsaveview()
  au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif
