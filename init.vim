" If vundle isn't installed then clone it to the right place
silent ! [ -x ~/.config/nvim/autoload ]
if v:shell_error
    silent ! curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs 
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

call plug#begin("~/.config/nvim/plugins")
Plug 'airblade/vim-gitgutter'
Plug 'nvim-lualine/lualine.nvim'
Plug 'fatih/vim-go'
Plug 'nvim-lua/plenary.nvim' 
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope-fzy-native.nvim', { 'do': 'make' }
Plug 'kyazdani42/nvim-tree.lua'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'kyazdani42/nvim-web-devicons'
Plug 'rafamadriz/friendly-snippets'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-syntastic/syntastic'
Plug 'majutsushi/tagbar'
Plug 'ruanyl/vim-gh-line'
Plug 'ellisonleao/glow.nvim', {'branch': 'main'}
Plug 'carlsmedstad/vim-bicep'
Plug 'catppuccin/nvim', {'as': 'catppuccin'}
Plug 'folke/trouble.nvim'
Plug 'neovim/nvim-lspconfig'
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
let g:catppuccin_flavour = "mocha" " latte, frappe, macchiato, mocha
" change with Catppuccin frappe


lua << EOF
require("catppuccin").setup{
  integrations = {
    nvimtree = true,
    telescope = true,
    treesitter = true
  },
  dim_inactive = {
    enabled = true,
    shade = "light",
    percentage = 1
  }
}

require('lualine').setup {
  options = {
    theme = "catppuccin"
  }
}

-- disable netrw at the very start of your init.lua (strongly advised) -- nvim-tree related
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

require'lspconfig'.gopls.setup{}
require('nvim-web-devicons').setup {default = true;}
require("nvim-tree").setup({
view = {
    mappings = {
      list = {
        { key = "s", action = "vsplit" },
        { key = "i", action = "split" },
      },
    },
  },
})
require("trouble").setup{}

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

colorscheme catppuccin

"syntastic stuff
set statusline+=%#warningmsg#
set statusline+=%*

" Better :sign interface symbols
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '!'
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_python_checkers = ['pycodestyle']
let g:syntastic_shell_checkers = ['shellcheck']
let g:syntastic_yaml_checkers = ['yamllint']
let g:syntastic_json_checkers = ['jsonlint']
" let g:syntastic_html_checkers = ['tidy']
" let g:syntastic_javascript_checkers=['jshint']
"
" use goimports for formatting
let g:go_fmt_command = "goimports"

" turn highlighting on
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

let g:syntastic_go_checkers = ['go', 'golint', 'errcheck']

"tags stuff
nnoremap <silent> T :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_compact = 1

" nerdtree stuff
nnoremap <silent> <C-n> :NvimTreeToggle<CR>

let mapleader = "'"
" set shortcut for toggle line number
map "" :set invnumber<CR>

" Easier split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

autocmd User TelescopePreviewerLoaded setlocal wrap
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>

" augroup fmt
"   autocmd!
"   autocmd BufWritePre * undojoin | Neoformat
" augroup END

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
autocmd FileType javascript Spaces
autocmd FileType go Tabs
autocmd FileType html RTabs
autocmd FileType ruby RTabs

" folding
" set foldmethod=manual
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()
" set nofoldenable                     " Disable folding at startup.

" show > for tab, . for spaces and $ for eol. Enable with 'set list'
set listchars+=tab:>-,space:.

set switchbuf=newtab

set cursorline
" set cursorcolumn
"
" bind L to grep word under cursor
nnoremap L :execute 'Telescope grep_string search='.expand('<cword>')<CR>

" trouble bindings
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>
nnoremap gA <cmd>TroubleToggle lsp_definitions<cr>

" Add at the end the whole path of file
set statusline+=%F

nnoremap <leader>md <cmd>MarkdownPreviewToggle<cr>
" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 1

" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: mean the cursor position alway show at the middle of the preview page
"   top: mean the vim top viewport alway show at the top of the preview page
"   relative: mean the cursor position alway show at the relative positon of the preview page
" hide_yaml_meta: if hide yaml metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
" content_editable: if enable content editable for preview page, default: v:false
" disable_filename: if disable filename header for preview page, default: 0
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0,
    \ 'toc': {}
    \ }

" preview page title
" ${name} will be replace with the file name
let g:mkdp_page_title = '「${name}」'

" recognized filetypes
" these filetypes will have MarkdownPreview... commands
let g:mkdp_filetypes = ['markdown']
