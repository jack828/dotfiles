""""
" General Settings
""""
  let maplocalleader = ","
  let mapleader = "\<Space>"

  " auto install vim plug when needed
  if empty(glob("~/.config/nvim/autoload/plug.vim"))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall
  endif

  " Disable strange Vi defaults.
  set nocompatible

  " Turn on filetype plugins (:help filetype-plugin).
  filetype plugin indent on

  syntax enable
  set autoindent

  " Allow backspace in insert mode.
  set backspace=indent,eol,start

  " Disable octal format for number processing.
  set nrformats-=octal

  " Allow for mappings including `Esc`, while preserving
  " zero timeout after pressing it manually.
  set ttimeout
  set ttimeoutlen=100

  " write swap file after 250ms - quicker CursorHold
  set updatetime=250

  " Enable case-insensitive incremental search.
  set incsearch

  " Enable search highlighting.
  set hlsearch

  " Ignore case when searching.
  set ignorecase

  " Don't ignore case when search has capital letter
  " (although also don't ignore case by default).
  set smartcase

  " Always show window statuses, even if there's only one.
  set laststatus=2

  " Show the line and column number of the cursor position.
  set ruler

  " Rulers to visually identify line length
  set colorcolumn=80,120

  " Always show sign column, prevents layout shift
  set signcolumn=yes

  " Show the size of block one selected in visual mode.
  set showcmd

  " Autocomplete commands using nice menu in place of window status.
  " Enable `Ctrl-N` and `Ctrl-P` to scroll through matches.
  set wildmenu

  " For autocompletion, complete as much as you can.
  set wildmode=longest,full

  " When 'wrap' is on, display last line even if it doesn't fit.
  set display+=lastline

  " Set default whitespace characters when using `:set list`
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

  " Delete comment character when joining commented lines
  if v:version > 703 || v:version == 703 && has("patch541")
    set formatoptions+=j
  endif

  " Search upwards for tags file instead only locally
  if has('path_extra')
    setglobal tags-=./tags tags^=./tags;
  endif

  " Reload unchanged files automatically.
  set autoread

  " Support all kind of EOLs by default.
  set fileformats+=mac

  " Increase history size to 1000 items.
  set history=1000

  " Allow for up to 50 opened tabs on Vim start.
  set tabpagemax=50

  " Always save upper case variables to viminfo file.
  set viminfo^=!

  " Enable backup and undo files by default.
  let s:dir = has('win32')
      \ ? '$APPDATA/Vim'
      \ : isdirectory($HOME.'/Library')
      \ ? '~/Library/Vim'
      \ : empty($XDG_DATA_HOME)
      \ ? '~/.local/share/vim'
      \ : '$XDG_DATA_HOME/vim'
  let &backupdir = expand(s:dir) . '/backup//'
  let &undodir = expand(s:dir) . '/undo//'
  set undofile

  " Allow colour schemes to do bright colours without forcing bold.
  if &t_Co == 8 && $TERM !~# '^linux'
    set t_Co=16
  endif

  " Automatically create directories for backup and undo files.
  if !isdirectory(expand(s:dir))
    call system("mkdir -p " . expand(s:dir) . "/{backup,undo}")
  end

  " Highlight line under cursor. It helps with navigation.
  set cursorline

  " Keep 8 lines above or below the cursor when scrolling.
  set scrolloff=8

  " Keep 15 columns next to the cursor when scrolling horizontally.
  set sidescroll=1
  set sidescrolloff=15

  " If opening buffer, search first in opened windows.
  set switchbuf=usetab

  " Hide buffers instead of asking if to save them.
  set hidden

  " Wrap lines by default
  set wrap linebreak
  set showbreak=" "

  " Show line numbers on the sidebar.
  set number

  " Disable any annoying beeps on errors.
  set noerrorbells
  set visualbell

  " Don't parse modelines (google "vim modeline vulnerability").
  set nomodeline

  " Do not fold by default. But if, do it up to 3 levels.
  set foldmethod=indent
  set foldnestmax=3
  set nofoldenable

  " Enable mouse for scrolling and window resizing.
  set mouse=a

  " Disable swap to prevent annoying messages.
  set noswapfile

  " Show mode in statusbar, not separately.
  set noshowmode

  " Use dash as word separator.
  set iskeyword+=-

  " Set window title by default.
  set title

  " Always focus on split window.
  set splitright
  set splitbelow

  " copy/paste to system clipboard
  set clipboard=unnamed

  " show invisible characters
  set list

  " mor speed
  set lazyredraw
  set ttyfast

  " .h files are c, .hpp are c++
  let g:c_syntax_for_h=1
""""
" Mappings
""""
  vnoremap <silent> y y`]
  vnoremap <silent> p p`]
  nnoremap <silent> p p`]

  nnoremap H ^
  nnoremap L $

  " reduce pinky strain
  nnoremap <Leader>w :w<CR>

  " closes current buffer, but doesn't close the split that it is in
  nnoremap <Leader>q :bp\|bd #<CR>

  " buffer navigation fun
  nnoremap gh :bp<CR>
  nnoremap gl :bn<CR>
  " sue me
  nnoremap g<Left> :bp<CR>
  nnoremap g<Right> :bn<CR>

  " 'zoom' current split
  nnoremap <Leader>z :tabnew %<CR>
  nnoremap <Leader>Z :tabclose<CR>

  " Run tests using yarn
  " Requires a `yarn run-test` command in package.json
  " TODO make it so we can re-run the tests in this panel with `r`
  nnoremap <Leader>m <C-w>v :te yarn run-test %<CR>

  " Run file in node
  nnoremap <Leader>n <C-w>v :te node %<CR>

  " Allow saving of files as sudo when I forgot to start vim using sudo.
  cmap w!! w !sudo tee > /dev/null %

  " Replace word under cursor and re-yank word under cursor
  nnoremap rp viwpyiw

  " this is going to hurt...
  " nnoremap <Left> :echoe "Use h"<CR>
  " nnoremap <Right> :echoe "Use l"<CR>
  " nnoremap <Up> :echoe "Use k"<CR>
  " nnoremap <Down> :echoe "Use j"<CR>

  " hopefully this will ease the pain...
  inoremap jj <Esc>j
  inoremap kk <Esc>k

  " Close quickfix
  nmap <Insert> :ccl<CR>

  " Use `Ctrl-C` to clear the highlighting of :set hlsearch.
  nnoremap <silent> <C-C> :nohlsearch<CR><C-L>

  " Search & highlight word under cursor
  " I use # but rarely * (because # is fewer keypresses)
  " # searches forward, which is what I prefer
  nnoremap # *

  " Y yanks from the cursor to the end of line as expected. See :help Y.
  nnoremap Y y$

  " Allow easy navigation between wrapped lines.
  vmap j gj
  vmap k gk
  nmap j gj
  nmap k gk

  " Auto center on matched string.
  noremap n nzz
  noremap N Nzz

  " stop the command popup window from appearing. literally why
  map q: :q

"" Saved Macros
  " select function
  let @c = 'vf{%'
  " generate UUID and paste
  let @u = ":let @* = system('uuidgen')[:-2]\<CR>p"

"" Platform Specific
  if has('nvim')
    " use true colours in the terminal
    set termguicolors

    " TODO deprecated
    " makes the cursor a pipe in insert-mode, and a block in normal-mode
    :let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

    " remove terminals from the buffer list
    autocmd TermOpen * set nobuflisted
  endif

""""
" Plugins
""""
  call plug#begin()

  " Wakatime
  Plug 'wakatime/vim-wakatime'

  " Language support
  Plug 'sheerun/vim-polyglot'
    " interferes with treesitter indents
    let g:polyglot_disabled = ['autoindent']

  " Fuzzy file search
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
   " Replace awful centred modal with previously default behaviour
    let g:fzf_layout = { 'down': '40%' }

    " I've never gotten these to work...
    map <c-x><c-k> <Plug>(fzf-complete-word)
    imap <c-x><c-j> <Plug>(fzf-complete-file-ag)
    imap <c-x><c-l> <Plug>(fzf-complete-line)

    nnoremap <silent> <Leader>o :Files<CR>
    nnoremap <silent> <Leader>g :GFiles?<CR>
    nnoremap <silent> <Leader><Enter> :Buffers<CR>

  " Find in project
  Plug 'rking/ag.vim'
    nnoremap \ :Ag!<SPACE>

  " Better nodejs support
  " Used for opening file under cursor with gf
  Plug 'moll/vim-node', { 'for': 'javascript' }

  " Fancy icons (requires patched font)
  Plug 'nvim-tree/nvim-web-devicons'

  " Lua utils, common plugin dependency
  Plug 'nvim-lua/plenary.nvim'

  " File navigator
  Plug 'MunifTanjim/nui.nvim'
  Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x' }
      " Toggle file browser
      nmap <silent> <Tab><Tab> :Neotree filesystem position=left action=focus toggle<CR>
      " Reveal current file in browser
      nmap <silent> <Leader>f :Neotree filesystem position=left action=focus reveal<CR>

  " Comment code
  Plug 'numToStr/Comment.nvim'

  " Strip whitespace etc.
  Plug 'editorconfig/editorconfig-vim'

  " Autocomplete
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'saadparwaiz1/cmp_luasnip'

  set completeopt=menu,menuone,noselect

  " Autosave and autoread
  autocmd FocusLost,WinLeave * :silent! wall
  autocmd FocusGained,BufEnter * :silent! !

  " Git integration
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'
    nnoremap <silent> <Leader>b :Git blame<CR>

  " Multiple cursors
  Plug 'mg979/vim-visual-multi', { 'branch': 'master' }
    " Prevent newline when selecting completion with <CR>
    autocmd User visual_multi_mappings imap <buffer><expr> <CR> pumvisible() ? "\<C-Y>" : "\<Plug>(VM-I-Return)"

  " Show buffers as tabs
  Plug 'ap/vim-buftabline'

  " Copy current file path
  Plug 'bag-man/copypath.vim'
    nnoremap cp :CopyRelativePath<CR>

  " Faster keyboard navigation within files
  " Lua version of easymotion
  Plug 'phaazon/hop.nvim'
    nmap <silent> s :HopWord<CR>

  " Statusbar
  Plug 'nvim-lualine/lualine.nvim'

  " Add '.' powers to plugins
  Plug 'tpope/vim-repeat'

  " Edit surrounding quotes, etc.
  Plug 'tpope/vim-surround'

  " Close all other buffers
  Plug 'schickling/vim-bufonly'
    " Close all but current
    nnoremap go :BufOnly<CR>
    " Close all
    nnoremap goa :BufOnly<CR>:bd<CR>

  " auto close brackets
  " causes weird insertion errors on CR
  " Plug 'rstacruz/vim-closer'
  Plug 'LunarWatcher/auto-pairs'

  " Colour previews
  Plug 'ap/vim-css-color'

  " Register magic
  Plug 'tversteeg/registers.nvim'
    let g:registers_paste_in_normal_mode = 1
"
  " Painless vim/tmux pane navigation
  Plug 'christoomey/vim-tmux-navigator'

  " Spleling is hard
  Plug 'kamykn/spelunker.vim'
    set nospell
    set spelllang=en_gb
    set spellfile=$HOME/spell/en.utf-8.add

  " fancy splash, because something is stopping the default from being shown
  Plug 'mhinz/vim-startify'
    " When opening a file, _don't_ change directory
    let g:startify_change_to_dir = 1
    " But do change to the VCS root!
    let g:startify_change_to_vcs_root = 1

  " LSP and related magicks
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
  Plug 'ojroques/nvim-lspfuzzy'

  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'neovim/nvim-lspconfig'

  Plug 'pmizio/typescript-tools.nvim'

  " Function context via Treesitter
  Plug 'nvim-treesitter/nvim-treesitter-context'

  " Colour scheme
  Plug 'marko-cerovac/material.nvim'
  let g:material_style = 'darker'

  " Every now and then you should check :StartupTime
  " Plug 'tweekmonster/startuptime.vim'

  " Auto-disconnect LSP servers
  " Plug 'zeioth/garbage-day.nvim'

  call plug#end()

  " Set colour scheme
  set termguicolors
  set background=dark
  colorscheme material

  " Set spell colours _after_ colourscheme
  highlight SpelunkerSpellBad cterm=undercurl ctermfg=196 gui=undercurl guifg=#a70000
  highlight SpelunkerComplexOrCompoundWord cterm=undercurl ctermfg=196 gui=undercurl guifg=#a70000

" LUA
" oooh shiny new lua

  lua require('treesitter')
  lua require('completion')
  lua require('lsp')
  lua require('statusline')
  lua require('plugins')

  " show diagnostic on hover in popover cos the lines can be loooooooooooong
  autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, { focus = false })

  " easymotion replacement - file navigation
  lua require('hop').setup()

  " for 'tversteeg/registers.nvim'
  lua require('registers').setup()

  " for 'numToStr/Comment.nvim'
  lua require('comment')

  " for 'nvim-tree/nvim-web-devicons'
  lua require('nvim-web-devicons').setup({})

  " for 'nvim-neo-tree/neo-tree.nvim'
  lua require('neo-tree').setup({
  \   close_if_last_window = true,
  \   window = {
  \     width = 30,
  \     mappings = {
  \       ["a"] = {
  \         "add",
  \         config = {
  \           show_path = "relative"
  \         }
  \       },
  \       ["A"] = {
  \         "add_directory",
  \         config = {
  \           show_path = "relative"
  \         }
  \       },
  \       ["c"] = {
  \         "copy",
  \         config = {
  \           show_path = "relative"
  \         }
  \       },
  \       ["m"] = {
  \         "move",
  \         config = {
  \           show_path = "relative"
  \         }
  \       }
  \     }
  \   },
  \   filesystem = {
  \     filtered_items = {
  \       hide_dotfiles = false,
  \       hide_gitignored = false,
  \       never_show = {
  \         ".git",
  \         ".DS_Store",
  \         "thumbs.db"
  \       }
  \     }
  \   }
  \ })

