-- set runtimepath^=~/.vim runtimepath+=~/.vim/after
-- let &packpath=&runtimepath
-- source ~/.vimrc

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  'jbyuki/quickmath.nvim',

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Add a bunch of useful linux commands to command mode
  'tpope/vim-eunuch',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Better "gf" for javascript
  'hotoo/jsgf.vim',

  {
  "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  -- multi cursor for nvim
  -- {
  --   "smoka7/multicursors.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     'smoka7/hydra.nvim',
  --   },
  --   opts = {},
  --   cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
  --   keys = {
  --     {
  --       mode = { 'v', 'n' },
  --       'C-n',
  --       '<cmd>MCstart<cr>',
  --       desc = 'Create a selection for selected text or word under the cursor',
  --     },
  --   },
  -- },

  -- make surround things really easier, this is a must have
  { 'tpope/vim-surround' },

  -- { 'github/copilot.vim' },

  {
  'jsongerber/nvim-px-to-rem',
    opts={}
  },

  -- vim blade syntax highlight
  'Eduruiz/vim-blade',

  -- Trying mini-files since I'm sick of nerdtree bugs
  {
    'echasnovski/mini.files',
    version = 'false',
    opts = {},
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
  },

  -- sneak like plugin but with some more sauce in it
  {
    'ggandor/leap.nvim',
    config = function()
      require('leap').create_default_mappings()
    end,
    dependencies = {
      'tpope/vim-repeat'
    }
  },
  {
    'voldikss/vim-floaterm',
    keys = {
      { '<F1>', ':FloatermToggle<CR>' },
      { '<F1>', '<C-\\><C-n>:FloatermToggle<CR>', mode = 't' },
    },
    cmd = { 'FloatermToggle' },
    init = function()
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8
    end,
  },
  {
    'petertriho/nvim-scrollbar',
    opts = {
      -- show_in_active_only = true,
      excluded_filetypes = {
        'neo-tree',
      },
      marks = {
        Cursor = {
          text = " ",
          priority = 99,
        },
      },
      handle = {
        blend = 90,
        highlight = "Cursor",
      },
    }
  },
  {
    'nvim-pack/nvim-spectre', -- Great find and replace project wide
    opts = {},
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Copilot like AI code autocomplete
  {
  'Exafunction/codeium.vim',
    -- require("codeium").setup({});
    config = function ()
      -- Change '<C-g>' here to any keycode you like.
      vim.g.codium_chat_enabled = true
      vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
      vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
      vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
      vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
    end
  },
  -- {
  --   'rest-nvim/rest.nvim',
  --   opts = {},
  --   dependencies = { "luarocks.nvim" },
  -- },

  -- Auto session management
  -- restore last opened buffers, windows and keep cursor position
  { 'rmagatti/auto-session', opts= {} },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      "mlaursen/vim-react-snippets",

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

    -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   lazy = false,
  --   config = function()
  --     require('onedark').setup {
  --       -- Set a style preset. 'dark' is default.
  --       style = 'warm', -- dark, darker, cool, deep, warm, warmer, light
  --     }
  --     require('onedark').load()
  --   end,
  -- },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = { -- test
      on_colors = function (colors)
        local util = require('tokyonight.util')
        colors.gitSigns = {
          add = colors.teal,
          change = colors.purple,
          delete = colors.red,
        }
      end,
      on_highlights = function(hl, c)
        local util = require('tokyonight.util')
        local prompt = "#2d3149"

        hl.BufferlineInactive = {
          bg = c.bg_dark,
        }
        hl.BufferlineActiveSeparator = {
          bg = c.bg,
          fg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
        hl.BufferlineInactiveSeparator = {
          bg = c.bg_dark,
          fg = util.darken(c.bg_dark, 0.85, '#000000'),
        }

        hl.NeoTreeFileNameOpened = {
          fg = c.orange,
        }

        hl.GitSignsCurrentLineBlame = {
          fg = c.fg_gutter,
        }

        -- Tabs
        hl.TabActive = {
          bg = c.bg,
        }
        hl.TabActiveSeparator = {
          bg = c.bg,
          fg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
        hl.TabInactive = {
          bg = c.bg_dark,
        }
        hl.TabInactiveSeparator = {
          bg = c.bg_dark,
          fg = util.darken(c.bg_dark, 0.85, '#000000'),
        }

        hl.SidebarTabActive = {
          bg = c.bg_dark,
        }
        hl.SidebarTabActiveSeparator = {
          bg = c.bg_dark,
          fg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
        hl.SidebarTabInactive = {
          bg = util.darken(c.bg_dark, 0.75, '#000000'),
          fg = c.comment,
        }
        hl.SidebarTabInactiveSeparator = {
          bg = util.darken(c.bg_dark, 0.75, '#000000'),
          fg = util.darken(c.bg_dark, 0.85, '#000000'),
        }


        hl.StatusLine = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
          fg = c.fg_dark,
        }
        hl.StatusLineComment = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
          fg = c.comment,
        }

        hl.LineNrAbove = {
          fg = c.fg_gutter,
        }
        hl.LineNr = {
          fg = util.lighten(c.fg_gutter, 0.7),
        }
        hl.LineNrBelow = {
          fg = c.fg_gutter,
        }

        hl.MsgArea = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
        }

        -- Spelling
        hl.SpellBad = {
          undercurl = true,
          sp = '#7F3A43',
        }

        -- Telescope
        hl.TelescopeNormal = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopePromptNormal = {
          bg = prompt,
        }
        hl.TelescopePromptBorder = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePromptTitle = {
          bg = c.bg,
          fg = c.fg_dark,
        }
        hl.TelescopePreviewTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopeResultsTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }

        -- Indent
        hl.IblIndent = {
          fg = c.bg_highlight,
        }
        hl.IblScope = {
          fg = util.lighten(c.bg_highlight, 0.95),
        }

        -- Floaterm
        hl.Floaterm = {
          bg = prompt,
        }
        hl.FloatermBorder = {
          bg = prompt,
          fg = prompt,
        }

        -- Copilot
        hl.CopilotSuggestion = {
          fg = c.comment,
        }

        -- NvimTree
        hl.NvimTreeIndentMarker = {
          fg = c.bg_highlight,
        }
        hl.NvimTreeOpenedFile = {
          fg = c.fg,
          bold = true
        }
        hl.NvimTreeNormal = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
        hl.NvimTreeNormalNC = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
        hl.NvimTreeWinSeparator = {
          fg = util.darken(c.bg_dark, 0.85, '#000000'),
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
      end,
    },
    config = function (plugin, opts)
      require('tokyonight').setup(opts)

      vim.cmd('colorscheme tokyonight')
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1, -- relative path
          }
        }
      },
      tabline = {
        lualine_a = {'buffers'},
      },
    },
  },


  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-tree/nvim-web-devicons'
    },
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'nvim-tree/nvim-tree.lua',
    opts = {
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    },
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})


-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'


-- Set hybrid line numbers
vim.opt.relativenumber = true

-- Set spell checking
vim.opt.spelllang = 'en_us,pt_br'
vim.opt.spell = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    layout_config = {
      preview_width = 50,
      horizontal = {
        width = 0.9,
        preview_cutoff = 0,
      },
    },
    path_display = {
      "smart"
    },
    mappings = {
      i = {
        ['<C-;>'] = require('telescope.actions.layout').toggle_preview

        -- ['<C-u>'] = false,
        -- ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>b', require('telescope.builtin').buffers, { desc = 'Find existing [b]uffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end

-- Custom telescope layout for file grep since when grepping
-- I usually care more about the file contents
local function telescope_live_grep()
  require('telescope.builtin').live_grep {
    layout_config = {
      preview_width = 70,
      horizontal = {
        width = 0.9,
        preview_cutoff = 0,
      },
    },
    path_display = {
      "smart"
    },
  }
end

vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>f', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', telescope_live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>st', require('telescope.builtin').tags, { desc = '[S]earch [T]Tags' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = true,
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- List of parsers to ignore installing
    ignore_install = {},
    -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
    modules = {},
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = {'scss'},
    },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.HINT]  = "",
      [vim.diagnostic.severity.INFO]  = "",
    },
  },
})

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  stylelint_lsp = { filetypes = { 'css', 'scss', 'vue' } },
  ts_ls = {},
  html = { filetypes = { 'html', 'vue', 'blade', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
require("vim-react-snippets").lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = "codeium" }
  },
}

-- Insert mode mappings to quickly exit to normal mode
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', {noremap = true})
vim.api.nvim_set_keymap('i', 'kj', '<Esc>', {noremap = true})
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', {noremap = true})
vim.api.nvim_set_keymap('i', 'kk', '<Esc>', {noremap = true})

-- easy use of ; as : no need to use shift :)
vim.api.nvim_set_keymap('n', ';', ':', {noremap = true})

-- remap ctrl+s to save, not really 'vim way', but I'm used to
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', {noremap = true})
vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:w<CR>a', {noremap = true})

-- Toggle spell check on and of with key shortcut
vim.api.nvim_set_keymap('n', '<F3>', ':setlocal spell! spelllang=en_us<CR>', {noremap = true})

-- Update misspelled word to first suggestion
vim.api.nvim_set_keymap('n', '<Leader>z', '1z=', {noremap = true, desc = 'Fix word spell with first suggestion'})

-- Navigate between split windows using Ctrl + direction keys
vim.api.nvim_set_keymap('n', '<C-J>', '<C-W><C-J>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-K>', '<C-W><C-K>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-H>', '<C-W><C-H>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-L>', '<C-W><C-L>', {noremap = true})

-- words I can't get right
vim.cmd([[iabbrev lenght length]])

-- Define a command to prettify JSON using Python's json.tool
vim.cmd("command! -nargs=0 PrettifyJson %!python3 -m json.tool")


-- Laravel specific maps
vim.api.nvim_set_keymap('n', '<Leader>lr', ':e routes/web.php<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>lc', ':e config/app.php<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>lv', ':e resources/views/<CR>', {noremap = true})

-- Make it easy to edit frequent general files
vim.api.nvim_set_keymap('n', '<Leader>ov', ':e ~/.config/nvim/init.lua<CR>', {noremap = true, desc = 'Open nvim config file' })
vim.api.nvim_set_keymap('n', '<Leader>or', ':so ~/.config/nvim/init.lua<CR>', {noremap = true, desc = 'Reload nvim config' })
vim.api.nvim_set_keymap('n', '<Leader>oh', ':e ~/Dropbox/docs/appcivico/hours.md<CR>', {noremap = true, desc = 'Open hours md file' })
vim.api.nvim_set_keymap('n', '<Leader>op', ':e ~/Dropbox/docs/appcivico/proposta<CR>', {noremap = true, desc = 'Open proposal file' })
vim.api.nvim_set_keymap('n', '<Leader>ot', ':e ~/Dropbox/docs/appcivico/vagas.md<CR>', {noremap = true, desc = 'Open job op file' })
vim.api.nvim_set_keymap('n', '<Leader>ok', ':e ~/.config/kitty/kitty.conf<CR>', {noremap = true, desc = 'Open job op file' })

-- Add minifiles shortcut
vim.api.nvim_set_keymap('n', '<F2>', ':lua MiniFiles.open()<CR>', {noremap = true, desc = 'Open minifiles explorer'})

-- Map <C-6> to execute the LastBuffer command in normal mode
vim.api.nvim_set_keymap('n', '<C-6>', ':b#<CR>', {noremap = true})

-- Add shortcut to quick close buffer
vim.api.nvim_set_keymap('n', '<Leader>x', ':bd<CR>', {noremap = true, desc = 'Close current buffer'})


-- Define a Lua function to create a new HTTP request file and execute it using rest-nvim
local function http_request()
    -- Get the start and end columns of the visual selection
    local start_col = vim.fn.col("'<")
    local end_col = vim.fn.col("'>")

    -- Get the line containing the visual selection
    local selected_line = vim.fn.getline("'<")

    -- Extract the visually selected text within the line
    local selected_text = selected_line:sub(start_col, end_col)

    -- Create a new buffer and set its filetype to http
    vim.cmd('enew')
    vim.bo.filetype = 'http'

    -- Ask the user if this is a GET or POST request
    local method = vim.fn.input('Is this a GET or POST request? (1 for get, 2 for post, default is get): ')
    if method == '' or method == '1' then
        method = 'GET'
    elseif method == '2' then
        method = 'POST'
    else
        print('Invalid input. Using default method (GET).')
        method = 'GET'
    end

    -- Write the HTTP request to the new file
    local request = method .. ' ' .. selected_text
    vim.fn.append(0, request)

    -- Run rest-nvim
    vim.cmd('lua require("rest-nvim").run()')
end

vim.api.nvim_create_user_command('HttpRequest', http_request, {})

vim.api.nvim_set_keymap('v', '<Leader>gr', ':<C-u>HttpRequest<CR>', {noremap = true})
