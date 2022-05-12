" If vundle isn't installed then clone it to the right place
silent ! [ -x ~/.config/nvim/autoload ]
if v:shell_error
    silent ! curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs 
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

call plug#begin("~/.config/nvim/plugins")
Plug 'airblade/vim-gitgutter'
Plug 'nvim-lualine/lualine.nvim'

Plug 'nvim-lua/plenary.nvim' 
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-telescope/telescope-fzy-native.nvim', { 'do': 'make' }
Plug 'scrooloose/nerdtree'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'kyazdani42/nvim-web-devicons'
Plug 'rafamadriz/friendly-snippets'
Plug 'sbdchd/neoformat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'mhartington/oceanic-next'
call plug#end()

" run if file doesn't exist
silent ! [ -e ~/.config/nvim/last-sync ]
if v:shell_error
    silent PlugInstall
    q
    silent ! touch ~/.config/nvim/last-sync
endif

" run if file is newer
silent ! [ ~/.config/nvim/init.vim -nt ~/.config/nvim/last-sync ]
if !v:shell_error
    silent PlugInstall
    q
    silent ! touch ~/.config/nvim/last-sync
endif


" Theme
syntax enable
colorscheme OceanicNext

" nerdtree stuff
nnoremap <silent> <C-n> :NERDTreeToggle<CR>

let mapleader = "'"
" set shortcut for toggle line number
map " :set invnumber<CR>

" Easier split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

autocmd User TelescopePreviewerLoaded setlocal wrap
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>

augroup fmt
  autocmd!
  autocmd BufWritePre * undojoin | Neoformat
augroup END

lua << END
require('lualine').setup()
require('nvim-web-devicons').setup {default = true;}
END

com Spaces set
    \ autoindent
    \ fo=tcr
    \ shiftwidth=4
    \ softtabstop=4
    \ expandtab

com Tabs set
    \ noexpandtab
    \ autoindent
    \ tabstop=4
    \ shiftwidth=4
    \ noexpandtab

com RTabs set
    \ noexpandtab
    \ autoindent
    \ tabstop=2
    \ shiftwidth=2
    \ softtabstop=2
    \ noexpandtab

autocmd FileType python Spaces
autocmd FileType javascript Tabs
autocmd FileType go Tabs
autocmd FileType html RTabs
autocmd FileType ruby RTabs


" show > for tab, . for spaces and $ for eol. Enable with 'set list'
set listchars+=tab:>-,space:.

set switchbuf=newtab
" set shortcut for toggle line number
map " :set invnumber<CR>

set cursorline
" set cursorcolumn
"
" bind L to grep word under cursor
nnoremap L :execute 'Telescope grep_string search='.expand('<cword>')<CR>
