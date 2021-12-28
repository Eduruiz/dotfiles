set nocompatible                                    "Always use latest version of vim (I think)

so ~/.vim/plugins.vim

let mapleader = ' '                                 "The default is \, but a space is much better.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Turn on the wild menu
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

"no text wrap
set nowrap

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Understand hyphened words as words
set iskeyword+=-

"custom ctrl+p ignore pattern
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|jpg|png|gif|ico|git|svn))$'


"remap Gundo key
nnoremap <F5> :GundoToggle<CR>

" making clipboard unnamed to work with OS clipboard
set clipboard=unnamed


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Remaps
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"-------------Jeff stuff I'm learning--------------"

set hidden                                                              "Automatically write the file when switching buffers.
set belloff=all                                                         "Disable annoying noise on gvim
set tabstop=2
set expandtab
set softtabstop=2
set shiftwidth=2
set ff=unix                                                             "Auto-convert line breaking in unix like
set autoread                                                            "Automatically reread changed files without asking me anything
set noshowmatch                                                           "Do not show matching brackets by flickering
let php_htmlInStrings = 1



"-------------Visual stuff--------------"
:set formatoptions-=t                                                   "Disable vim auto indentation on some width
let g:enable_italic_font = 1                                            "Enable italic fonts on comments
"let g:enable_bold_font = 1                                             "Enable some fonts to be bold
set background=dark
"vim cool colorschemes
" colorscheme OceanicNext
let g:gruvbox_italic=1                                                  " enbale gruvbox italic fonts on terminal
colorscheme omni
" colorscheme nova
let g:airline_theme = "oceanicnext"                                         "Enable hybrid theme on airline 
" let g:airline_theme = "oceanicnext"                                   "Enable hybrid theme on airline 
set guioptions-=m                                                       "remove menu bar
set guioptions-=T                                                       "remove toolbar
set guioptions-=r                                                       "remove right-hand scroll bar
set guioptions-=L                                                       "remove left-hand scroll bar

set number                                                              "show line numbers
set smartindent                                                         "when new line on insert mode, keep indentation
set cursorline                                                          "highlight current line under cursor
set termguicolors                                                       "use gui colors on terminal when supported
autocmd ColorScheme * highlight clear LineNr | highlight clear SignColumn "Use same color from editor bg on git gutter column
set list listchars=tab:\ \ ,trail:·                                     " Display tabs and trailing spaces visually
"underline matching parents
hi MatchParen term=underline cterm=underline gui=underline
"disable bg and fg color of matching parents
hi MatchParen gui=none guifg=none guibg=none

hi Normal guibg=NONE ctermbg=NONE
hi ColorScheme guibg=NONE ctermbg=NONE
autocmd ColorScheme * highlight Normal guibg=None
" autocmd ColorScheme * highlight NonText ctermbg=None

"force syntax to aways be nice, danger zone 'cause it can be slow
autocmd BufEnter * :syntax sync fromstart





set number relativenumber

"-------------Split Management--------------"
set splitbelow                                                           " Make splits default to below...
set splitright                                                           " And to the right. This feels more natural.

"We'll set simpler mappings to switch between splits.
nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-H> <C-W><C-H>
nmap <C-L> <C-W><C-L>




"-------------History and undo stuff--------------"
set history=10000                                                         " Store a ton of history
set undofile                                                            "Turn on the feature, this make persistent undo after writing file
set undodir=$HOME/.vim/undo//                                            "Directory where the undo files will be stored, this NEED to exist beforehand




" Make it obvious where 120 characters is {{{
" Lifted from StackOverflow user Jeremy W. Sherman
" http://stackoverflow.com/a/3765575/2250435
if exists('+colorcolumn')
  set textwidth=120
  set colorcolumn=+1
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1)
endif " }}}



"-------------Plugins--------------"
"/
"/ Ag vim
"/
command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>,
  \                 <bang>0 ? fzf#vim#with_preview('right:50%')
  \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
  \                 <bang>0)




"/
"/ fzf
"/
nmap <Leader>b :Buffers<CR>
nmap <Leader>f :Files<CR>
nmap <Leader>t :Tags<CR>
nmap <Leader>g :Ag<CR>

" general
" let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()' }
" let $FZF_DEFAULT_OPTS="--reverse "                                         " top to bottom

" use rg by default
" if executable('ag')
"   let $FZF_DEFAULT_COMMAND = 'ag --files --hidden --follow --glob "!.git/*"'
"   set grepprg=ag\ --vimgrep
" endif

"}}}

"{{{ ======================== Filetype-Specific Configurations ============================= "

" enable spell only if file type is normal text
" let spellable = ['markdown', 'gitcommit', 'txt', 'text']
" autocmd BufEnter * if index(spellable, &ft) < 0 | set nospell | else | set spell | endif

" open help in vertical split
" autocmd FileType help wincmd L

" startify when there is no open buffer left
" autocmd BufDelete * if empty(filter(tabpagebuflist(), '!buflisted(v:val)')) | Startify | endif

" open startify on start
" autocmd VimEnter * if argc() == 0 | Startify | endif

" open files preview on enter and provided arg is a folder
" autocmd VimEnter * if argc() != 0 && isdirectory(argv()[0]) | Startify | endif
" autocmd VimEnter * if argc() != 0 && isdirectory(argv()[0]) | execute 'cd' fnameescape(argv()[0])  | endif
" autocmd VimEnter * if argc() != 0 && isdirectory(argv()[0]) | Files | endif

" auto html tags closing, enable for markdown files as well
" let g:closetag_filenames = '*.html,*.xhtml,*.phtml, *.md'

" disable autosave on kernel directory and also formatting on save (we dont wanna fuck this up)
" autocmd BufRead,BufNewFile */Dark-Ages/* let b:auto_save = 0
" autocmd BufRead,BufNewFile */Dark-Ages/* let b:ale_fix_on_save = 0

"}}}
"{{{ ================== Custom Functions ===================== "

" files window with preview
" command! -bang -nargs=? -complete=dir Files
"         \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)


" advanced grep(faster with preview)
" function! RipgrepFzf(query, fullscreen)
"     let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
"     let initial_command = printf(command_fmt, shellescape(a:query))
"     let reload_command = printf(command_fmt, '{q}')
"     let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
"     call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
" endfunction
" command! -nargs=* -bang Rg call RipgrepFzf(<q-args>, <bang>0)
"
" " floating fzf window with borders
" function! CreateCenteredFloatingWindow()
"     let width = min([&columns - 4, max([80, &columns - 20])])
"     let height = min([&lines - 4, max([20, &lines - 10])])
"     let top = ((&lines - height) / 2) - 1
"     let left = (&columns - width) / 2
"     let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}
"
"     let top = "╭" . repeat("─", width - 2) . "╮"
"     let mid = "│" . repeat(" ", width - 2) . "│"
"     let bot = "╰" . repeat("─", width - 2) . "╯"
"     let lines = [top] + repeat([mid], height - 2) + [bot]
"     let s:buf = nvim_create_buf(v:false, v:true)
"     call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
"     call nvim_open_win(s:buf, v:true, opts)
"     set winhl=Normal:Floating
"     let opts.row += 1
"     let opts.height -= 2
"     let opts.col += 2
"     let opts.width -= 4
"     call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
"     au BufWipeout <buffer> exe 'bw '.s:buf
" endfunction

" show docs on things with K
" function! s:show_documentation()
"   if (index(['vim','help'], &filetype) >= 0)
"     execute 'h '.expand('<cword>')
"   else
"     call CocAction('doHover')
"   endif
" endfunction



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
"/ polyglot
"/
"
let g:polyglot_disabled = ['blade']



"/
"/ IndentLine
"/
let g:indentLine_concealcursor = 0





"/
"/ IndentLine
"/

" for e in emoji#list()
"   call append(line('$'), printf('%s (%s)', emoji#for(e), e))
" endfor
set completefunc=emoji#complete





"/
"/ vim sessions
"/
let g:session_autosave = 'yes'                                           "autosave session on quit
let g:session_autoload = 'yes'                                            "get rid of dialog asking if you want to load the last session
let g:session_default_to_last = 1                                        "autoload last saved session




"/
"/ Deoplete
"/
" let g:deoplete#enable_at_startup = 1
" inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
" inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
" autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif:q




"/
"/  nvim completion manager
"/
" don't give |ins-completion-menu| messages.  For example,
" 'xxx completion (yyy)', 'match 1 of 2', 'The only match'
set shortmess+=c
" When the <Enter> key is pressed while the popup menu is visible, it only hides the menu.
" this mapping hide the menu and also start a new line.
" inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
" Use <TAB> to select the popup menu:
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"






"/
"/  nvim completion manager
"/
let g:mta_use_matchparen_group = 1
let g:mta_filetypes = {
    \ 'html' : 1,
    \ 'xhtml' : 1,
    \ 'xml' : 1,
    \ 'php' : 1,
    \}







"/
"/ Neosnippet
"/
let g:neosnippet#enable_completed_snippet = 1






"/
"/ Flygrep
"/
" nnoremap <Space>g :FlyGrep<cr> Commented becaus now I'm using Ag! instead


"/
"/ ultisnips
"/
" make YCM compatible with UltiSnips (using supertab)
" let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
" let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
" let g:SuperTabDefaultCompletionType = '<C-n>'
"
" " better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "noop"
let g:UltiSnipsJumpForwardTrigger = "noop"
let g:UltiSnipsJumpBackwardTrigger = "noop"
let g:UltiSnipsSnippetDirectories = ['~/.vim/UltiSnips', 'UltiSnips']



" filetype plugin indent on

"/
"/ Ctrl+P
"/

"let g:ctrlp_cmd = 'CtrlPMixed'			" search anything (in files, buffers and MRU files at the same time.)
let g:ctrlp_working_path_mode = 'ra'	        " search for nearest ancestor like .git, .hg, and the directory of the current file
" let g:ctrlp_by_filename = 1
let g:ctrlp_max_height = 10			" maximum height of match window
let g:ctrlp_switch_buffer = 'et'		" jump to a file if it's open already
let g:ctrlp_use_caching = 1			" enable caching
let g:ctrlp_clear_cache_on_exit=0  		" speed up by not removing clearing cache every time
let g:ctrlp_mruf_max = 250 			" number of recently opened files
let g:ctrlp_show_hidden = 1                     " let ctrlp see the hidden files





"/
"/ AckVim
"/
" Tell ack.vim to use ag (the Silver Searcher) instead
let g:ackprg = 'ag --vimgrep'


lua << EOF
  local nvim_lsp = require('lspconfig')
  local servers = { 'tsserver', 'vuels', 'eslint' }

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    buf_set_keymap('n', '<space>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    
    -- my new commands
    buf_set_keymap('n', '<space>af', '<cmd>EslintFixAll<CR>', opts)
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

  -- basically does:
  -- require'lspconfig'.[server].setup{<options>}
  for index, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      capabilities = capabilities,
      on_attach = on_attach
    }
  end

  -- nvim-cmp
  local cmp = require('cmp')
  local lspkind = require('lspkind')
  local luasnip = require('luasnip')

  -- better autocompletion experience
  vim.o.completeopt = 'menuone,noselect'

  cmp.setup {
    -- Format the autocomplete menu
    formatting = {
      format = lspkind.cmp_format()
    },
    mapping = {
      -- Use Tab and shift-Tab to navigate autocomplete menu
      ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
        ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
        end,
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
      },
      snippet = {
          expand = function(args)
              luasnip.lsp_expand(args.body)
          end
      },
      sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
      },
  }


  -- treesitter
  local treesitter = require('nvim-treesitter.configs')
  treesitter.setup {
    highlight = {
      enable = true,
      -- additional_vim_regex_highlighting = false,
    }
  }

EOF



"/
"/ coc vim
"/
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
" use <tab> for trigger completion and navigate to the next complete item

" function! s:check_back_space() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~ '\s'
" endfunction
"
" inoremap <silent><expr> <Tab>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<Tab>" :
"       \ coc#refresh()
"
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"
" function! s:check_back_space() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~# '\s'
" endfunction

" airline integration
" let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
" let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
" Use <c-space> for trigger completion.
" inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use K for show documentation in preview window
" nnoremap <silent> K :call <SID>show_documentation()<CR>

" function! s:show_documentation()
"   if &filetype == 'vim'
"     execute 'h '.expand('<cword>')
"   else
"     call CocAction('doHover')
"   endif
" endfunction

"list extensions
" let s:coc_extensions = [
" \   'coc-css',
" \   'coc-html',
" \   'coc-json',
" \   'coc-emmet',
" \   'coc-emoji',
" \   'coc-eslint',
" \   'coc-stylelintplus',
" \   'coc-prettier',
" \   'coc-tsserver',
" \   'coc-vetur',
" \   'coc-ultisnips'
" \ ]

"loop and install the extensions
" for extension in s:coc_extensions
"     call coc#add_extension(extension)
" endfor

" Remap keys for gotos
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

" Highlight symbol under cursor on CursorHold
" autocmd CursorHold * silent call CocActionAsync('highlight')

"/
"/ Emmet vim
"/
" let g:user_emmet_expandabbr_key='<Tab>'     "expand stuff using tab from emmet (st like)
let g:user_emmet_install_global = 0
"configure emmet to run on those specific file types
autocmd FileType html,vue,php,css,scss,sass EmmetInstall
let g:user_emmet_expandabbr_key='<C-e>'
" imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")
let g:user_emmet_mode='i' "only use emmet on insert mode



let g:user_emmet_next_key = '<C-w>'
" let g:user_emmet_prev_key = ''



"/
"/ syntastic
"/

let g:syntastic_always_populate_loc_list = 1     "Those are the recommended settings from syntastic
let g:syntastic_auto_loc_list = 1                "I don't really know what's going on here, but will
let g:syntastic_check_on_open = 1                "update as soon as things make more sense to me
let g:syntastic_check_on_wq = 0



"/
"/ tagalong 
"/

let g:tagalong_additional_filetypes = ['vue']



"/
"/ sneak
"/
let g:sneak#label = 1
let g:sneak#s_next = 1 "activate 'smart s' to go to next matchs with s
nmap <expr> <Tab> sneak#is_sneaking() ? '<Plug>Sneak_;' : '<Tab>'
nmap <expr> <S-Tab> sneak#is_sneaking() ? '<Plug>Sneak_,' : '<S-Tab>'





"/
"/ ALE - syntax linting async
"/
" let g:ale_sign_warning = '▲'
" let g:ale_sign_error   = '✗'
" highlight link ALEWarningSign String
" highlight link ALEErrorSign Title
" " Highlight errors on airline
" let g:airline#extensions#ale#enabled = 1
" nmap <Leader>af :ALEFix<cr>
" " Fix files with prettier, and then ESLint.
" let g:ale_linter_aliases = {'vue': ['vue', 'javascript', 'css']}
" let g:ale_linters = {'vue': ['eslint', 'vls', 'stylelint']}
"
" let g:ale_fixers = {
" \ 'javascript': ['eslint'],
" \ 'vue': ['eslint'],
" \ 'typescript': ['eslint'],
" \ 'javascript.jsx': ['prettier'],
" \ 'javascriptreact': ['prettier'],
" \ 'css': ['stylelint'],
" \ 'scss': ['stylelint'],
" \ }

" let g:ale_fix_on_save=1






"/
"/ nerdtree
"/
let NERDTreeShowHidden=1
let g:NERDTreeWinPos = "left"



"/
"/ airline
"/

set enc=utf8
syntax enable on

let g:Powerline_symbols = 'fancy'
set laststatus=2 "always show powerline
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
"/ vim-multiple-cursor
"/
let g:multi_cursor_exit_from_insert_mode = 0


"/
"/ javascript libraries
"/

let g:used_javascript_libs = 'jquery,vue,react'



" Automatically calculate import cost on js files
" this may be a little slow, but let test it out
" this depends on import-cost plugin supporting vue
" by now it makes no sense to use it
" augroup import_cost_auto_run
"   autocmd!
"   autocmd InsertLeave *.js,*.jsx,*.ts,*.tsx ImportCost
"   autocmd BufEnter *.js,*.jsx,*.ts,*.tsx ImportCost
"   autocmd CursorHold *.js,*.jsx,*.ts,*.tsx ImportCost
" augroup END



"-------------Mappings--------------"
"quicky search visual selection
vnoremap // y/\V<C-r>=escape(@",'/\')<CR><CR>
"Make it easy to edit frequent general files
nmap <Leader>ev :e ~/.vimrc<cr>
nmap <Leader>ep :e ~/.vim/plugins.vim<cr>
nmap <Leader>es :e ~/.vim/snippets/
nmap <Leader>er :so ~/.vimrc<cr>
nmap <Leader>eh :e ~/Dropbox/docs/appcivico/hours.md<cr>
nmap <Leader>et :e ~/Dropbox/docs/appcivico/vagas.md<cr>

"Add simple highlight removal.
nmap <Leader><Leader> :nohlsearch<cr>


"Yank to + register in visual mode
vnoremap Y "+y

"Quickly browse to any tag/symbol in the project.
"Tip: run ctags -R to regenerated the index.
" nmap <Leader>f :tag<space>

"Easy scape from insert mode
inoremap jk <esc>
inoremap kj <esc>
inoremap jj <esc>
" inoremap kk <esc>

"Easy scape from terminal mode
tnoremap <esc> <C-\><C-N>

"easy use of ; as : no need to use shift :)
nnoremap ; :


"remap ctrl+s to save, not really 'vim way', but I'm used to
nmap <c-s> :w<cr>
imap <c-s> <esc>:w<cr>a


"copy to linux clipboard
nnoremap YY "+Y

" Quick work with buffers
nnoremap <Leader><Leader>bd :bd<cr>

"quick open and close NerdTREE
map <F2> :NERDTreeToggle<CR>                                                 

"drag and duplicate selected text with arrow keys
vmap  <expr>  <LEFT>   DVB_Drag('left')                                     
vmap  <expr>  <RIGHT>  DVB_Drag('right')
vmap  <expr>  <DOWN>   DVB_Drag('down')
vmap  <expr>  <UP>     DVB_Drag('up')
vmap  <expr>  D        DVB_Duplicate()


" Toggle spell check on and of with key shortcut
map <F3> :setlocal spell! spelllang=en_us<CR>
nmap <Leader>z 1z=
autocmd FileType gitcommit setlocal spell

" adjust tab to indent on insert mode, needed because tab is remapped to expand emmet stuff
" imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")




" words I can't get right
iab lenght length


"-------------new commands--------------"
command PrettifyJson :%!python -m json.tool




"-------------Neocomplete 2--------------"
"enable in all buffers
" autocmd BufEnter * call ncm2#enable_for_buffer()
":help Ncm2PopupOpen for more information
" set completeopt=noinsert,menuone,noselect




"-------------whatever?--------------"
nmap <Leader>ee :e .env<cr>


"-------------Laravel-Specific--------------"
nmap <Leader>lr :e routes/web.php<cr>
nmap <Leader>lc :e config/app.php<cr>
nmap <Leader>lm :!php artisan make:
nmap <Leader>lm :CtrlP<cr>app/
nmap <Leader>lv :e resources/views/<cr>





"-------------Codeigniter-Specific--------------"
"open config.php file in application/config or in app/application/config
nnoremap <expr> <Leader>cc !empty(glob("application/config/config.php")) ? ':e application/config/config.php<cr>' : ':e app/application/config/config.php<cr>'
"open routes.php file in application/config or in app/application/config
nnoremap <expr> <Leader>cr !empty(glob("application/config/routes.php")) ? ':e application/config/routes.php<cr>' : ':e app/application/config/routes.php<cr>'
nnoremap <expr> <Leader>cd !empty(glob("application/config/database.php")) ? ':e application/config/database.php<cr>' : ':e app/application/config/database.php<cr>'



"-------------Auto-Commands--------------"
"automatically source the vimrc file on save.
"ok, let's break this in parts - first pip is sourcing vimrc,
"second one is clearing line numbers, so it get the same color as the bg
"third one is doing the same, but with SignColumn (used by gitgutter)
"fourth one is refreshing airline, so the tabs don't loose it's colors
autocmd! bufwritepost ~/.vimrc source ~/.vimrc | highlight clear LineNr | AirlineRefresh | highlight clear SignColumn



"automatically rum csscomb on csslike files
" autocmd BufWritePost silent *.scss !csscomb %

"automatically jump to last know cursor position on file
if v:version >= 700
  au BufLeave * let b:winview = winsaveview()
  au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif
