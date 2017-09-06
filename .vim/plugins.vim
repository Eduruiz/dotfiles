filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'altercation/vim-colors-solarized'
Plugin 'flazz/vim-colorschemes'
Plugin 'Kazark/vim-SimpleSmoothScroll'
Plugin 'mattn/emmet-vim'
Plugin 'ap/vim-css-color'
Plugin 'ervandew/supertab'
Plugin 'atweiden/vim-dragvisuals'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'jordwalke/flatlandia'
Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'http://github.com/sjl/gundo.vim.git'
Plugin 'tpope/vim-surround'
Plugin 'kristijanhusak/vim-hybrid-matrial'
Plugin 'wting/gitsessions.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
Plugin 'airblade/vim-gitgutter'
Plugin 'sirver/ultisnips'
Plugin 'scrooloose/syntastic'

" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
