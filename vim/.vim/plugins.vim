if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source ~/.vimrc
endif

call plug#begin('~/.vim/plugged')
    Plug 'tpope/vim-fugitive'                                   " this is a git wrapper that add some git commands to vim, I kind of don't use it
    Plug 'scrooloose/nerdtree'                                  " nerdtree is a good 'gui' for file navigation, really nice
    Plug 'flazz/vim-colorschemes'
    " Plug 'mattn/emmet-vim'                                      " emmet for vim, html/css expander/autocomplete
    Plug 'atweiden/vim-dragvisuals'                             " plugin to select text (visual mode) and easy drag it using arrow keys (remaps needed)
    " Plug 'vim-airline/vim-airline'                              " airline, show nice infos on the bottom bar (I think you know what airline/powerline is)
    " Plug 'vim-airline/vim-airline-themes'                       " airline themes
    Plug 'nvim-tree/nvim-web-devicons'                          " Recommended for coloured icons (lualine and bufferline) 
    Plug 'nvim-lualine/lualine.nvim'                            " a line written in lua (dã)
    Plug 'akinsho/bufferline.nvim'                              " nice buffers visualizer
    Plug 'tpope/vim-surround'                                   " make surround things and changing surroundings easier
    Plug 'xolox/vim-misc'                                       " this plugin is a requirement to vim-session work
    Plug 'xolox/vim-session'                                    " manage vim sessions like sublime text
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}         " multiple cursors, sublime like but more powerful
    Plug 'airblade/vim-gitgutter'                               " git tab showing git status of file
    " Plug 'sirver/ultisnips'                                     " testing ultisnips
    " Plug 'honza/vim-snippets'                                   " utilsnips snippets are separated
    " Plug 'Yggdroot/indentLine'                                  " here we create a little line to show matching indentations
    Plug 'tomtom/tcomment_vim'                                  " easy comment stuff
    Plug 'godlygeek/tabular'                                    " quickly align text on tabular formats
    " Plug 'jiangmiao/auto-pairs'                                 " auto close quotes/brackets and stuff like that
    Plug 'trevordmiller/nova-vim'                               " another good looking colorscheme
    Plug 'mhartington/oceanic-next'                             " another great theme
    Plug 'johngrib/vim-game-code-break'                         " code break game, just for the lols
    Plug 'mileszs/ack.vim'                                      " ack vim, a grep better then grep
    Plug 'junegunn/fzf'                                         " the base fzf plugin
    Plug 'junegunn/fzf.vim'                                     " vim fzf integration, good fuzzyfinder tool
    Plug 'junegunn/vim-emoji'                                   " emoji for vim
    Plug 'junegunn/goyo.vim'                                        " distraction free
    Plug 'Eduruiz/vim-blade'
    Plug 'metakirby5/codi.vim'                                  " a live interactive scratchpad for programming languages
    Plug 'editorconfig/editorconfig-vim'                        " editorconfig plugin for vim
    Plug 'ryanoasis/vim-devicons'                               " vim development icons
    Plug 'wsdjeg/FlyGrep.vim'                                   " spacevim flygrep
    Plug 'tpope/vim-repeat'                                     " make vim reapeat command compatible with some plugins
    Plug 'posva/vim-vue'                                        " vue syntax
    Plug 'cakebaker/scss-syntax.vim'                            " scss syntax
    Plug 'danhodos/vim-comb'                                    " reorder css properties automatically
    Plug 'chiedo/vim-px-to-em'                                  " convert pixels to ems
    Plug 'Oldenborg/vim-px-to-rem'                              " convert pixels to rems
    Plug 'vim-scripts/CSSMinister'                              " convert hex colort to rgb
    Plug 'ludovicchabant/vim-gutentags'                         " auto generate ctags for projects
    Plug 'tpope/vim-eunuch'                                     " Vim sugar for the UNIX shell commands that need it the most.
    Plug 'lambdalisue/suda.vim'                                 " Plugin to write as sudo on neovim (https://github.com/neovim/neovim/issues/1716)
    Plug 'EpicVoyage/Expression-Engine-Vim-syntax'              " expression engine vim syntax
    Plug 'junegunn/vim-peekaboo'                                " show you the contents of the registers
    " Plug 'AndrewRadev/tagalong.vim'                             " Change an HTML(ish) opening tag and take the closing one along as well
    Plug 'justinmk/vim-sneak'                                   " Jump to any location specified by two characters.
    Plug 'sk1418/HowMuch'                                       " Easily do quick math with visual selections
    " Plug 'shmargum/vim-sass-colors'                             " Show sass colors
    " Plug 'codota/tabnine-vim'                                   " Tabnine, AI completion (I'm not even sure it's working)
    " Plug 'yardnsm/vim-import-cost', { 'do': 'npm install' }   " Nice way to show import sizes but not usefull on vim yet (https://github.com/wix/import-cost/issues/23)
    "
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-pack/nvim-spectre'                               " cool find and replace

    "themes
    Plug 'kristijanhusak/vim-hybrid-material'                   " really good looking theme
    Plug 'dracula/vim'                                          " dracula theme for vim :)
    Plug 'shaunsingh/nord.nvim'                                 " just another theme
    Plug 'yonlu/omni.vim'                                       " just another theme
    Plug 'Mofiqul/vscode.nvim'                                  " theme treesitter ready
    Plug 'morhetz/gruvbox'                                      " classic vim theme
    Plug 'pappasam/papercolor-theme-slim'                       " papercolor treesitter ready
    Plug 'svermeulen/text-to-colorscheme.nvim'                  " ai text to theme plugin



    " Let's try LSP
    " First we disable coc
    " Plug 'neoclide/coc.nvim', {'branch': 'release'}             " Testing COC autocompletion (vscode like they say)
    Plug 'sheerun/vim-polyglot'                                 " vim syntax highlight for everything
    " Plug 'ncm2/ncm2'                                            " neo completion manager version 2
    Plug 'nelsyeung/twig.vim'                                     " twig syntax highlighting
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}    "nvim better highlight using treesitter

    " autocomplete with LSP
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'onsails/lspkind-nvim'




    "testing
    " Plug 'camspiers/animate.vim'                                " lens dependency to animatey window transitions
    " Plug 'camspiers/lens.vim'                                   " make focused buffer bigger
    Plug 'wellle/targets.vim'                                     " better text targets (I think)
    Plug 'windwp/nvim-ts-autotag'                                 " Testing new autotag since the old one is messing up my files
    Plug 'williamboman/mason.nvim'                                " easily manage external editor tooling such as LSP servers, DAP servers, linters, and formatters through a single interface
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'nvim-telescope/telescope-ui-select.nvim'                " telescope cute ui plugin

    Plug 'HerringtonDarkholme/yats.vim'                           " JSX pretty dependency
    Plug 'yuezk/vim-js'                                           " JSX pretty dependency
    Plug 'maxmellon/vim-jsx-pretty'                               " prettier jsx syntax



    " Plug 'captbaritone/better-indent-support-for-php-with-html' " better html/php indent
    " Plug 'roxma/nvim-yarp'
    Plug 'brooth/far.vim'                                       " find and replace nicier than default
    " Plug 'mattn/vim-starwars'
    " Plug 'StanAngeloff/php.vim'
    " Plug 'dsifford/php.vim'
    Plug '2072/php-indenting-for-vim'
    " Plug 'othree/html5.vim'                                     " better html5 syntax
    " Plug 'JulesWang/css.vim'                                    " Better css colors
    " Plug 'Valloric/MatchTagAlways'                              " always highlight html matching tags
    " Plug 'MarcWeber/vim-addon-mw-utils'                         " vim snipmate depends on this
    " Plug 'tomtom/tlib_vim'                                      " vim snipmate depends on this too
    " Plug 'garbas/vim-snipmate'                                  " textual snippets and tab jumping
    " Plug 'tpope/vim-vinegar'                                    " lighter then nerdtree, uses default vim stuff to show files
    " Plug 'gko/vim-coloresque'                                   " show css colors as colors
    " Plug 'ervandew/supertab'
    " Plug 'ncm2/ncm2'                                            "neo completion manager version 2
    " Plug 'roxma/nvim-yarp'                                      "required fom ncm2 
    " Plug 'ncm2/ncm2-cssomni'
    " Plug 'ncm2/ncm2-tern'
    " Plug 'roxma/nvim-cm-tern',  {'do': 'npm install'}
call plug#end()

