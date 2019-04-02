if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source ~/.vimrc
endif

call plug#begin('~/.vim/plugged')
    Plug 'tpope/vim-fugitive'                                   " this is a git wrapper that add some git commands to vim, I kind of don't use it
    Plug 'kien/ctrlp.vim'                                       " if you know sublime ctrp, this is the closest I can get in vim
    Plug 'scrooloose/nerdtree'                                  " nerdtree is a good 'gui' for file navigation, really nice
    Plug 'flazz/vim-colorschemes'
    Plug 'tpope/vim-vinegar'                                    " lighter then nerdtree, uses default vim stuff to show files
    Plug 'mattn/emmet-vim'                                      " emmet for vim, html/css expander/autocomplete
    "Plug 'gko/vim-coloresque'                                   " show css colors as colors
    "Plug 'ervandew/supertab'
    Plug 'atweiden/vim-dragvisuals'                             " plugin to select text (visual mode) and easy drag it using arrow keys (remaps needed)
    Plug 'vim-airline/vim-airline'                              " airline, show nice infos on the bottom bar (I think you know what airline/powerline is)
    Plug 'vim-airline/vim-airline-themes'                       " airline themes
    Plug 'tpope/vim-surround'                                   " make surround things and changing surroundings easier
    Plug 'kristijanhusak/vim-hybrid-material'                   " really good looking theme
    Plug 'morhetz/gruvbox'                                      " classic vim theme
    Plug 'xolox/vim-misc'                                       " this plugin is a requirement to vim-session work
    Plug 'xolox/vim-session'                                    " manage vim sessions like sublime text
    Plug 'terryma/vim-multiple-cursors'                         " multiple cursors, sublime like but more powerful
    " Plug 'MarcWeber/vim-addon-mw-utils'                         " vim snipmate depends on this
    " Plug 'tomtom/tlib_vim'                                      " vim snipmate depends on this too
    " Plug 'garbas/vim-snipmate'                                  " textual snippets and tab jumping
    Plug 'airblade/vim-gitgutter'                               " git tab showing git status of file
    Plug 'sirver/ultisnips'                                     " testing ultisnips
    Plug 'honza/vim-snippets'                                   " utilsnips snippets are separated
    Plug 'w0rp/ale'                                             " same as syntastic, a syntax checker but assync
    Plug 'Yggdroot/indentLine'                                  " here we create a little line to show matching indentations
    Plug 'tomtom/tcomment_vim'                                  " easy comment stuff
    Plug 'brooth/far.vim'                                       " find and replace nicier than default
    Plug 'godlygeek/tabular'                                    " quickly align text on tabular formats
    Plug 'captbaritone/better-indent-support-for-php-with-html' " better html/php indent
    Plug 'jiangmiao/auto-pairs'                                 " auto close quotes/brackets and stuff like that
    Plug 'trevordmiller/nova-vim'                               " another good looking colorscheme
    Plug 'mhartington/oceanic-next'                             " another great theme
    Plug 'johngrib/vim-game-code-break'                         " code break game, just for the lols
    Plug 'mileszs/ack.vim'                                      " ack vim, a grep better then grep
    Plug 'junegunn/fzf'                                         " the base fzf plugin
    Plug 'junegunn/fzf.vim'                                     " vim fzf integration, good fuzzyfinder tool
    Plug 'junegunn/vim-emoji'                                   " emoji for vim
    Plug 'sheerun/vim-polyglot'                                 " vim syntax highlight for everything
    " Plug 'StanAngeloff/php.vim'
    " Plug 'dsifford/php.vim'
    " Plug '2072/php-indenting-for-vim'
    " Plug 'othree/html5.vim'                                     " better html5 syntax
    " Plug 'JulesWang/css.vim'                                    " Better css colors
    " Plug 'Valloric/MatchTagAlways'                              " always highlight html matching tags
    Plug 'metakirby5/codi.vim'                                  " a live interactive scratchpad for programming languages
    Plug 'roxma/nvim-yarp'
    Plug 'editorconfig/editorconfig-vim'                        " editorconfig plugin for vim
    Plug 'ryanoasis/vim-devicons'                               " vim development icons
    Plug 'wsdjeg/FlyGrep.vim'                                   " spacevim flygrep
    Plug 'tpope/vim-repeat'                                     " make vim reapeat command compatible with some plugins
    Plug 'posva/vim-vue'                                        " vue syntax
    Plug 'cakebaker/scss-syntax.vim'                            " scss syntax
    Plug 'csscomb/vim-csscomb'                                  " scss linter
    Plug 'chiedo/vim-px-to-em'                                  " convert pixels to ems
    Plug 'vim-scripts/CSSMinister'                              " convert hex colort to rgb
    Plug 'ludovicchabant/vim-gutentags'                         " auto generate ctags for projects
    Plug 'tpope/vim-eunuch'                                     " Vim sugar for the UNIX shell commands that need it the most.
    Plug 'lambdalisue/suda.vim'                                 " Plugin to write as sudo on neovim (https://github.com/neovim/neovim/issues/1716)
    Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}} "testing COC autocompletion (vscode like they say)




    " Plug 'ncm2/ncm2'                                            "neo completion manager version 2
    " Plug 'roxma/nvim-yarp'                                      "required fom ncm2 
    " Plug 'ncm2/ncm2-cssomni'
    " Plug 'ncm2/ncm2-tern'
    " Plug 'roxma/nvim-cm-tern',  {'do': 'npm install'}

" Initialize plugin system
call plug#end()
