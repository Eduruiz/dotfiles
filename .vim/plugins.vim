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
    Plug 'tpope/vim-vinegar'                                " lighter then nerdtree, uses default vim stuff to show files
    Plug 'mattn/emmet-vim'                                      " emmet for vim, html/css expander/autocomplete
    Plug 'gko/vim-coloresque'                                   " show css colors as colors
    Plug 'ervandew/supertab'
    Plug 'atweiden/vim-dragvisuals'                             " plugin to select text (visual mode) and easy drag it using arrow keys (remaps needed)
    Plug 'cakebaker/scss-syntax.vim'                            " scss syntax for vim
    Plug 'vim-airline/vim-airline'                              " airline, show nice infos on the bottom bar (I think you know what airline/powerline is)
    Plug 'vim-airline/vim-airline-themes'                       " airline themes
    Plug 'http://github.com/sjl/gundo.vim.git'                  " add undo functionalities
    Plug 'tpope/vim-surround'                                   " make surround things and changing surroundings easier
    Plug 'kristijanhusak/vim-hybrid-material'                   " really good looking theme
    Plug 'xolox/vim-misc'                                       " this plugin is a requirement to vim-session work
    Plug 'xolox/vim-session'                                    " manage vim sessions like sublime text
    Plug 'terryma/vim-multiple-cursors'                         " multiple cursors, sublime like but more powerful
    Plug 'MarcWeber/vim-addon-mw-utils'                         " vim snipmate depends on this
    Plug 'tomtom/tlib_vim'                                      " vim snipmate depends on this too
    Plug 'garbas/vim-snipmate'                                  " textual snippets and tab jumping
    Plug 'airblade/vim-gitgutter'                               " git tab showing git status of file
    Plug 'sirver/ultisnips'                                     " testing ultisnips
    Plug 'honza/vim-snippets'                                   " utilsnips snippets are separated
    Plug 'w0rp/ale'                                             " same as syntastic, a syntax checker but assync
    Plug 'Yggdroot/indentLine'                                  " here we create a little line to show matching indentations
    Plug 'tpope/vim-commentary'                                 " easy comment stuff
    Plug 'brooth/far.vim'                                       " find and replace nicier than default
    Plug 'godlygeek/tabular'                                    " quickly align text on tabular formats
    Plug 'captbaritone/better-indent-support-for-php-with-html' " better html/php indent
    Plug 'jiangmiao/auto-pairs'                                 " auto close quotes/brackets and stuff like that
    Plug 'posva/vim-vue'                                        " better vue with vim
    Plug 'pangloss/vim-javascript'                              " better javascript with vim
    Plug 'jelera/vim-javascript-syntax'                         " much better javascript with vim :)
    Plug 'xsbeats/vim-blade'                                    " laravel blade syntax from vim
    Plug 'mxw/vim-jsx'                                          " better react syntax for vim
    Plug 'craigemery/vim-autotag'                               " auto generate ctags based on project 'tags' file
    Plug 'mhartington/oceanic-next'                             " another great theme
    Plug 'johngrib/vim-game-code-break'                         " code break game, just for the lols
    Plug 'mileszs/ack.vim'                                      " ack vim, a grep better then grep
    Plug 'junegunn/fzf'                                         " the base fzf plugin
    Plug 'junegunn/fzf.vim'                                     " vim fzf integration, good fuzzyfinder tool


    " The sparkup vim script is in a subdirectory of this repo called vim.
    " Pass the path to set the runtimepath properly.
    Plug 'rstacruz/sparkup', {'rtp': 'vim/'}

" Initialize plugin system
call plug#end()
