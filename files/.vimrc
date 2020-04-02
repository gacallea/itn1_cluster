"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" source: https://github.com/gacallea/itn1_cluster
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               VIM SPECIFIC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible                " be iMproved, also required by Vundle
filetype off                    " required by Vundle
set showcmd		                " Show (partial) command in status line.
set showmatch		            " Show matching brackets.
set ignorecase		            " Do case insensitive matching
set smartcase		            " Do smart case matching
set hlsearch                    " Highlight all current search terms
set incsearch		            " Incremental search
set autowrite		            " Automatically save before commands like :next and :make
set hidden                      " Hide buffers when they are abandoned
set number                      " Enable line numbers
set wildmenu                    " Enable command-line completion operates in an enhanced mode.
set encoding=utf-8              " Set Vim encding to UTF-8
set paste                       " Retain pasted text formatting and indentation when pasting
set nowrap                      " Disable text wrapping
set smarttab                    " <Tab> in front of a line inserts blanks according to 'sw' 'ts' or 'sts'
set expandtab                   " In Insert mode use the appropriate number of spaces to insert a <Tab>.
set tabstop=4 softtabstop=4 shiftwidth=4
set autoindent                  " indent when moving to the next line while writing code
set showmatch                   " show the matching part of the pair for [] {} and ()
let python_highlight_all = 1    " enable all Python syntax highlighting features
set nofoldenable                " disable folding

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               VUNDLE
"               check https://vimawesome.com/ for more awesome plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle
" see :help vundle for more details or wiki for FAQ
set rtp+=~/.vim/bundle/vundle/  " required
call vundle#begin()             " required
" let Vundle manage Vundle      " required
Plugin 'gmarik/vundle'
" Power-ups :
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'bling/vim-bufferline'
Plugin 'Lokaltog/powerline-fonts'
" Code Helpers :
Plugin 'w0rp/ale' " https://github.com/w0rp/ale
Plugin 'Chiel92/vim-autoformat' " https://github.com/Chiel92/vim-autoformat
Plugin 'skywind3000/asyncrun.vim' " https://github.com/skywind3000/asyncrun.vim
Plugin 'stephpy/vim-yaml' " https://github.com/stephpy/vim-yaml
Plugin 'elzr/vim-json' " https://github.com/elzr/vim-json
" Tools :
Plugin 'scrooloose/nerdtree'
Plugin 'ervandew/supertab'
Plugin 'gerw/vim-HiLinkTrace'
" Others :
Plugin 'godlygeek/tabular'
call vundle#end()               " required
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               VIM AFTER VUNDLE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on                     " Vim syntax highlighting
filetype plugin indent on     " required by Vundle
" jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               VIM MAPPING COMMODITIES
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use <leader>l to toggle display of whitespace
nmap <leader>l :set list!<CR>
" And set some nice chars to do it with
set listchars=tab:»\ ,eol:¬
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                   VIM TAB SPACES FOR INDIVIDUAL LANGUAGES
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd Filetype bash setlocal ts=4 sts=4 sw=4
autocmd Filetype python setlocal ts=4 sts=4 sw=4
autocmd Filetype json setlocal ts=4 sts=4 sw=4
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               VIM TOOLS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NerdTreeToggle via f2
map <f2> :NERDTreeToggle<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               VIM LOOK
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Airline setup
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline_theme='bubblegum'

"augroup vimrc_autocmds
"  autocmd FileType * highlight Excess ctermbg=DarkGrey guibg=Black
"  autocmd FileType * match Excess /\%79v.*/
"  autocmd FileType * highlight UnwantedSpaces ctermbg=DarkGrey guibg=Black
"  autocmd FileType * 2match UnwantedSpaces /\s\+$/
"augroup END

" Use dark background for dark terminal
set background=dark
colorscheme desert

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               Python specific:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" YAPF autoformat
autocmd FileType python nnoremap <LocalLeader>= :0,$!yapf<CR>

" ASyncRun
" Quick run via <F5>
nnoremap <F5> :call <SID>compile_and_run()<CR>

augroup SPACEVIM_ASYNCRUN
    autocmd!
    " Automatically open the quickfix window
    autocmd User AsyncRunStart call asyncrun#quickfix_toggle(15, 1)
augroup END

function! s:compile_and_run()
    exec 'w'
    if &filetype == 'c'
        exec "AsyncRun! gcc % -o %<; time ./%<"
    elseif &filetype == 'cpp'
       exec "AsyncRun! g++ -std=c++11 % -o %<; time ./%<"
    elseif &filetype == 'sh'
       exec "AsyncRun! time bash %"
    elseif &filetype == 'python'
       exec "AsyncRun! time python %"
    endif
endfunction
