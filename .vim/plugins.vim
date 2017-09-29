        filetype off                  " required

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()

    " let Vundle manage Vundle, required
    Plugin 'gmarik/Vundle.vim'
    Plugin 'MarcWeber/vim-addon-mw-utils'
    Plugin 'tpope/vim-fugitive' "this is a git wrapper that add some git commands to vim, I kind of don't use it
    Plugin 'kien/ctrlp.vim' "if you know sublime ctrp, this is the closest I can get in vim
    Plugin 'scrooloose/nerdtree' "nerdtree is a good 'gui' for file navigation, really nice
    Plugin 'flazz/vim-colorschemes'
    Plugin 'Kazark/vim-SimpleSmoothScroll' "smooooth scrolling in vim
    Plugin 'tpope/vim-vinegar.git' "lighter then nerdtree, uses default vim stuff to show files
    Plugin 'mattn/emmet-vim' "emmet for vim, html/css expander/autocomplete
    Plugin 'gko/vim-coloresque' "show css colors as colors
    Plugin 'ervandew/supertab'
    Plugin 'atweiden/vim-dragvisuals' "plugin to select text (visual mode) and easy drag it using arrow keys (remaps needed)
    Plugin 'cakebaker/scss-syntax.vim' "scss syntax for vim
    Plugin 'vim-airline/vim-airline' "airline, show nice infos on the bottom bar (I think you know what airline/powerline is)
    Plugin 'vim-airline/vim-airline-themes' "airline themes
    "Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'} "powerline for vim, lots of cool infos in the bottom bar
    Plugin 'http://github.com/sjl/gundo.vim.git' "add undo functionalities
    Plugin 'tpope/vim-surround' "make surround things and changin surroundings easyer
    Plugin 'kristijanhusak/vim-hybrid-material' "really good looking theme
    Plugin 'xolox/vim-misc'  "this plugin is a requirement to vim-session work
    Plugin 'xolox/vim-session' "manage vim sessions like sublime text
    Plugin 'terryma/vim-multiple-cursors' "multiple cursors, sublime like but more powerful
    Plugin 'tomtom/tlib_vim'
    Plugin 'garbas/vim-snipmate'
    Plugin 'airblade/vim-gitgutter' "git tab showing git status of file
    Plugin 'sirver/ultisnips' "testing ultisnips
    Plugin 'honza/vim-snippets' "utilsnips snnipets are separated
    Plugin 'scrooloose/syntastic' "syntastic is syntax checker
    Plugin 'Yggdroot/indentLine' "here we create a little line to show matching indentations
    Plugin 'tpope/vim-commentary' "easy comment stuff 
    Plugin 'brooth/far.vim' "find and replace nicier than default
    Plugin 'captbaritone/better-indent-support-for-php-with-html' "better html/php indent
    Plugin 'jiangmiao/auto-pairs' "auto close quotes/brackets and stuff like that
    


" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
