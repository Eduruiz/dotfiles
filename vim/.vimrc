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
set noshowmatch                                                         "Do not show matching brackets by flickering
let php_htmlInStrings = 1


"------------- Theme --------------"
"vim cool colorschemes
" colorscheme OceanicNext
" let g:gruvbox_italic=1                                                  " enbale gruvbox italic fonts on terminal
" colorscheme omni
" colorscheme nova
" let g:airline_theme = "oceanicnext"                                     "Enable hybrid theme on airline
" let g:vscode_style = "dark"
" let g:vscode_transparency = 1
" colorscheme vscode
colorscheme PaperColorSlim




"-------------Visual stuff--------------"
:set formatoptions-=t                                                   "Disable vim auto indentation on some width
let g:enable_italic_font = 1                                            "Enable italic fonts on comments
"let g:enable_bold_font = 1                                             "Enable some fonts to be bold
set background=dark
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
set undofile                                                              " Turn on the feature, this make persistent undo after writing file
set undodir=$HOME/.vim/undo//                                             " Directory where the undo files will be stored, this NEED to exist beforehand




" Make it obvious where 120 characters is {{{
" Lifted from StackOverflow user Jeremy W. Sherman
" http://stackoverflow.com/a/3765575/2250435
if exists('+colorcolumn')
  set textwidth=100
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
" nmap <Leader>b :Buffers<CR>
" nmap <Leader>f :Files<CR>
" nmap <Leader>t :Tags<CR>
" nmap <Leader>g :Ag<CR>


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
  local actions = require('telescope.actions')require('telescope').setup{
  pickers = {
    buffers = {
        sort_lastused = true
      }
    }
  }

  require("bufferline").setup{}

  require('lualine').setup{
    sections = {
      lualine_c = {
        {
          'filename',
          file_status = true,      -- Displays file status (readonly status, modified status)
          path = 1,                -- 0: Just the filename
                                   -- 1: Relative path
                                   -- 2: Absolute path

          shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                                   -- for other components. (terrible name, any suggestions?)
          symbols = {
            modified = '[+]',      -- Text to show when the file is modified.
            readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
            unnamed = '[No Name]', -- Text to show for unnamed buffers.
          }
        }
      }
    }
  }

  local nvim_lsp = require('lspconfig')
  local servers = {
    'tsserver',
    'vuels',
    'html',
    'emmet_ls',
    'eslint',
    'cssls',
    'jsonls',
    'stylelint_lsp',
    'intelephense',
    'vimls'
  }

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
    buf_set_keymap('n', '<space>d', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    buf_set_keymap('n', '<space>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

      -- learn to set this in lua like another eduardo does here
      -- https://github.com/eduardoarandah/vimrc-public/blob/nvim/extra.vim
      -- function Fix()
      --   if(vim.bo.filetype == 'javascript') then
      --     return '!npx eslint --fix %'
      --   end
      --   if(vim.bo.filetype == 'scss') then
      --     return '!npx stylelint % --fix'
      --   end
      -- end
      --
      -- command! Fix :call Fix()
      -- buf_set_keymap('n', '<space>af', '<cmd>Fix<CR>', opts)

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

  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
EOF

"/
"/ Telescope
"/
nnoremap <leader>f <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>g <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>h <cmd>lua require('telescope.builtin').help_tags()<cr>



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
"/ nerdtree
"/
let NERDTreeShowHidden=1
let g:NERDTreeWinPos = "left"



"/
"/ airline
"/

" set enc=utf8
" syntax enable on
"
" let g:Powerline_symbols = 'fancy'
" set laststatus=2 "always show powerline
" set t_Co=256
" let g:airline_powerline_fonts = 1
" set fillchars+=stl:\ ,stlnc:\
" set termencoding=utf-8
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '|'
" " Just show the filename (no path) in the tab
" let g:airline#extensions#tabline#fnamemod = ':t'





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
" by now it makes no sense to use it (https://github.com/wix/import-cost/issues/23)
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
autocmd! bufwritepost ~/.vimrc source ~/.vimrc | highlight clear LineNr | highlight clear SignColumn



" automatically rum csscomb on csslike files
" autocmd BufWritePost silent *.scss !csscomb %

"automatically jump to last know cursor position on file
if v:version >= 700
  au BufLeave * let b:winview = winsaveview()
  au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif
